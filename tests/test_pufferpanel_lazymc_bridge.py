import http.server
import json
import os
import signal
import subprocess
import sys
import threading
import time
import urllib.parse


BRIDGE_BIN = sys.argv[1]


class MockPufferPanelState:
    def __init__(self, initially_running=False, expire_after_first_call=False):
        self.lock = threading.Lock()
        self.running = initially_running
        self.expire_after_first_call = expire_after_first_call
        self.token_counter = 0
        self.active_token = None
        self.starts = 0
        self.stops = 0
        self.status_calls = 0


def make_handler(state):
    class Handler(http.server.BaseHTTPRequestHandler):
        def log_message(self, format, *args):
            return

        def _send_json(self, status, payload=None):
            body = b"" if payload is None else json.dumps(payload).encode("utf-8")
            self.send_response(status)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            if body:
                self.wfile.write(body)

        def _check_auth(self):
            auth = self.headers.get("Authorization", "")
            with state.lock:
                expected = f"Bearer {state.active_token}"
                if not state.active_token or auth != expected:
                    return False
                if state.expire_after_first_call and state.token_counter == 1 and state.status_calls >= 1:
                    state.active_token = "expired"
                    return False
                return True

        def do_POST(self):
            length = int(self.headers.get("Content-Length", "0"))
            raw = self.rfile.read(length).decode("utf-8")

            if self.path == "/oauth2/token":
                form = urllib.parse.parse_qs(raw)
                if (
                    form.get("grant_type") != ["client_credentials"]
                    or form.get("client_id") != ["cid"]
                    or form.get("client_secret") != ["csecret"]
                ):
                    self._send_json(401, {"error": "invalid_client"})
                    return
                with state.lock:
                    state.token_counter += 1
                    state.active_token = f"tok-{state.token_counter}"
                    token = state.active_token
                self._send_json(200, {"access_token": token, "expires_in": 3600})
                return

            if not self._check_auth():
                self._send_json(401, {"error": "unauthorized"})
                return

            if self.path == "/api/servers/srv1/start":
                with state.lock:
                    state.starts += 1
                    state.running = True
                self._send_json(202)
                return

            if self.path == "/api/servers/srv1/stop":
                with state.lock:
                    state.stops += 1
                    state.running = False
                self._send_json(202)
                return

            self._send_json(404)

        def do_GET(self):
            if not self._check_auth():
                self._send_json(401, {"error": "unauthorized"})
                return

            if self.path == "/api/servers/srv1/status":
                with state.lock:
                    state.status_calls += 1
                    running = state.running
                self._send_json(200, {"running": running})
                return

            self._send_json(404)

    return Handler


def start_mock(state):
    server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), make_handler(state))
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    return server


def bridge_env(port):
    env = os.environ.copy()
    env.update(
        {
            "PUFFERPANEL_URL": f"http://127.0.0.1:{port}",
            "PUFFERPANEL_SERVER_ID": "srv1",
            "PUFFERPANEL_CLIENT_ID": "cid",
            "PUFFERPANEL_CLIENT_SECRET": "csecret",
            "PUFFERPANEL_POLL_INTERVAL": "0.1",
            "PUFFERPANEL_START_WAIT": "5",
            "PUFFERPANEL_STOP_TIMEOUT": "5",
        }
    )
    return env


def test_cold_start_eof_stdin_and_sigterm_stop():
    state = MockPufferPanelState(initially_running=False, expire_after_first_call=True)
    server = start_mock(state)
    try:
        proc = subprocess.Popen(
            [BRIDGE_BIN],
            env=bridge_env(server.server_address[1]),
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        deadline = time.monotonic() + 5
        while time.monotonic() < deadline:
            with state.lock:
                if state.starts == 1 and state.token_counter >= 2:
                    break
            time.sleep(0.05)

        assert proc.poll() is None, "bridge exited prematurely on EOF stdin or 401 refresh"
        proc.send_signal(signal.SIGTERM)
        out, err = proc.communicate(timeout=5)
        assert proc.returncode == 0, f"expected 0, got {proc.returncode}: {out} {err}"
        assert state.starts == 1
        assert state.stops == 1
        assert state.running is False
    finally:
        server.shutdown()


def test_attach_already_running_and_external_stop():
    state = MockPufferPanelState(initially_running=True)
    server = start_mock(state)
    try:
        proc = subprocess.Popen(
            [BRIDGE_BIN],
            env=bridge_env(server.server_address[1]),
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        time.sleep(0.3)
        assert proc.poll() is None
        assert state.starts == 0

        with state.lock:
            state.running = False
        out, err = proc.communicate(timeout=5)
        assert proc.returncode == 0, f"expected 0, got {proc.returncode}: {out} {err}"
        assert state.starts == 0
        assert state.stops == 0
    finally:
        server.shutdown()


def test_stdin_stop_command():
    state = MockPufferPanelState(initially_running=True)
    server = start_mock(state)
    try:
        proc = subprocess.Popen(
            [BRIDGE_BIN],
            env=bridge_env(server.server_address[1]),
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        time.sleep(0.2)
        out, err = proc.communicate("stop\n", timeout=5)
        assert proc.returncode == 0, f"expected 0, got {proc.returncode}: {out} {err}"
        assert state.stops == 1
        assert state.running is False
    finally:
        server.shutdown()


if __name__ == "__main__":
    test_cold_start_eof_stdin_and_sigterm_stop()
    test_attach_already_running_and_external_stop()
    test_stdin_stop_command()
