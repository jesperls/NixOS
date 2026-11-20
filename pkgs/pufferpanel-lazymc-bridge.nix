{ writers }:

writers.writePython3Bin "pufferpanel-lazymc-bridge" { } ''
  import json
  import os
  import signal
  import sys
  import threading
  import time
  import urllib.error
  import urllib.parse
  import urllib.request


  def log(message):
      print(f"[pufferpanel-lazymc-bridge] {message}", flush=True)


  class PufferPanelClient:
      def __init__(self, base_url, client_id, client_secret):
          self.base_url = base_url.rstrip("/")
          self.client_id = client_id
          self.client_secret = client_secret
          self._token = None
          self._expires_at = 0.0

      def _authenticate(self):
          body = urllib.parse.urlencode(
              {
                  "grant_type": "client_credentials",
                  "client_id": self.client_id,
                  "client_secret": self.client_secret,
              }
          ).encode("utf-8")
          req = urllib.request.Request(
              f"{self.base_url}/oauth2/token",
              data=body,
              method="POST",
              headers={"Content-Type": "application/x-www-form-urlencoded"},
          )
          with urllib.request.urlopen(req, timeout=15) as resp:
              data = json.loads(resp.read().decode("utf-8"))
          self._token = data["access_token"]
          expires_in = float(data.get("expires_in", 3600))
          self._expires_at = time.monotonic() + max(expires_in - 60.0, 30.0)

      def _ensure_token(self):
          if not self._token or time.monotonic() >= self._expires_at:
              self._authenticate()

      def request(self, method, path):
          for attempt in range(2):
              self._ensure_token()
              req = urllib.request.Request(
                  f"{self.base_url}{path}",
                  method=method,
                  headers={"Authorization": f"Bearer {self._token}"},
              )
              try:
                  with urllib.request.urlopen(req, timeout=15) as resp:
                      raw = resp.read()
                      if not raw:
                          return {}
                      return json.loads(raw.decode("utf-8"))
              except urllib.error.HTTPError as err:
                  if err.code == 401 and attempt == 0:
                      self._token = None
                      continue
                  raise

      def is_running(self, server_id):
          data = self.request("GET", f"/api/servers/{server_id}/status")
          return bool(data.get("running", False))

      def start_server(self, server_id):
          self.request("POST", f"/api/servers/{server_id}/start")

      def stop_server(self, server_id):
          self.request("POST", f"/api/servers/{server_id}/stop")


  def watch_stdin(stop_event):
      try:
          for line in sys.stdin:
              if line.strip().lower() == "stop":
                  log("Received 'stop' on stdin")
                  stop_event.set()
                  return
      except Exception:
          return


  def stop_and_wait(client, server_id, stop_timeout):
      log(f"Requesting graceful stop for server {server_id}")
      try:
          if not client.is_running(server_id):
              log("Server is already stopped")
              return 0
          client.stop_server(server_id)
      except Exception as err:
          log(f"Error requesting stop: {err}")
          return 1

      deadline = time.monotonic() + stop_timeout
      while time.monotonic() < deadline:
          try:
              if not client.is_running(server_id):
                  log("Server stopped cleanly")
                  return 0
          except Exception as err:
              log(f"Status poll failed during stop: {err}")
          time.sleep(min(2.0, max(0.1, deadline - time.monotonic())))

      log(f"Timed out waiting for server {server_id} to stop")
      return 1


  def main():
      base_url = os.environ.get("PUFFERPANEL_URL", "http://127.0.0.1:8080")
      server_id = os.environ.get("PUFFERPANEL_SERVER_ID", "").strip()
      client_id = os.environ.get("PUFFERPANEL_CLIENT_ID", "").strip()
      client_secret = os.environ.get("PUFFERPANEL_CLIENT_SECRET", "").strip()
      poll_interval = float(os.environ.get("PUFFERPANEL_POLL_INTERVAL", "5"))
      start_wait = float(os.environ.get("PUFFERPANEL_START_WAIT", "45"))
      stop_timeout = float(os.environ.get("PUFFERPANEL_STOP_TIMEOUT", "120"))
      max_errors = int(os.environ.get("PUFFERPANEL_MAX_POLL_ERRORS", "6"))

      if not server_id or not client_id or not client_secret:
          log(
              "Missing PUFFERPANEL_SERVER_ID, PUFFERPANEL_CLIENT_ID, "
              "or PUFFERPANEL_CLIENT_SECRET"
          )
          return 2

      stop_event = threading.Event()

      def handle_signal(signum, _frame):
          log(f"Received signal {signum}")
          stop_event.set()

      signal.signal(signal.SIGTERM, handle_signal)
      signal.signal(signal.SIGINT, handle_signal)

      stdin_thread = threading.Thread(
          target=watch_stdin, args=(stop_event,), daemon=True
      )
      stdin_thread.start()

      client = PufferPanelClient(base_url, client_id, client_secret)

      try:
          already_running = client.is_running(server_id)
      except Exception as err:
          log(f"Failed to query initial status: {err}")
          return 1

      if already_running:
          log(f"Server {server_id} is already running; attaching")
      else:
          log(f"Starting server {server_id} via PufferPanel")
          try:
              client.start_server(server_id)
          except Exception as err:
              log(f"Failed to start server {server_id}: {err}")
              return 1

          start_deadline = time.monotonic() + start_wait
          started = False
          while not stop_event.is_set() and time.monotonic() < start_deadline:
              try:
                  if client.is_running(server_id):
                      started = True
                      break
              except Exception as err:
                  log(f"Status poll failed during start: {err}")
              remaining = start_deadline - time.monotonic()
              stop_event.wait(min(2.0, max(0.1, remaining)))

          if stop_event.is_set():
              return stop_and_wait(client, server_id, stop_timeout)
          if not started:
              log(f"Server {server_id} did not enter running state in time")
              return 1
          log(f"Server {server_id} is running")

      consecutive_errors = 0
      while not stop_event.wait(poll_interval):
          try:
              running = client.is_running(server_id)
              consecutive_errors = 0
          except Exception as err:
              consecutive_errors += 1
              log(
                  f"Status poll error ({consecutive_errors}/{max_errors}): "
                  f"{err}"
              )
              if consecutive_errors >= max_errors:
                  return 1
              continue

          if not running:
              log(f"Server {server_id} stopped externally")
              return 0

      return stop_and_wait(client, server_id, stop_timeout)


  if __name__ == "__main__":
      sys.exit(main())
''
