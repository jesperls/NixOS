{ writers }:

writers.writePython3Bin "mc-host-gate" { } ''
  import asyncio
  import os
  import socket
  import sys


  MAX_HANDSHAKE_BYTES = 4096
  HANDSHAKE_TIMEOUT = 5.0
  UPSTREAM_CONNECT_TIMEOUT = 5.0
  COPY_CHUNK_SIZE = 65536


  def log(message):
      print(f"[mc-host-gate] {message}", flush=True)


  def sanitize(text):
      cleaned = "".join(ch if 32 <= ord(ch) < 127 else "?" for ch in text)
      return cleaned[:64]


  def read_varint(buf, offset):
      value = 0
      shift = 0
      while offset < len(buf):
          byte = buf[offset]
          offset += 1
          value |= (byte & 0x7F) << shift
          if not (byte & 0x80):
              return value, offset
          shift += 7
          if shift >= 35:
              raise ValueError("varint too long")
      return None, offset


  def extract_handshake_host(buf):
      packet_len, pos = read_varint(buf, 0)
      if packet_len is None:
          if len(buf) > 5:
              raise ValueError("malformed packet length")
          return None
      if packet_len <= 0 or packet_len > MAX_HANDSHAKE_BYTES:
          raise ValueError(f"invalid packet length {packet_len}")

      total_needed = pos + packet_len
      if len(buf) < total_needed:
          return None

      payload = buf[pos:total_needed]
      idx = 0

      packet_id, idx = read_varint(payload, idx)
      if packet_id != 0:
          raise ValueError(f"non-handshake packet id {packet_id}")

      proto, idx = read_varint(payload, idx)
      if proto is None:
          raise ValueError("truncated protocol version")

      addr_len, idx = read_varint(payload, idx)
      if addr_len is None or addr_len <= 0 or addr_len > 1024:
          raise ValueError("invalid server address length")
      if idx + addr_len + 2 > len(payload):
          raise ValueError("truncated server address")

      raw_addr = payload[idx:idx + addr_len].decode("utf-8")
      idx += addr_len + 2  # skip server port (uint16)

      next_state, idx = read_varint(payload, idx)
      if next_state not in (1, 2, 3):
          raise ValueError(f"invalid next state {next_state}")

      host = raw_addr.split("\x00", 1)[0].rstrip(".").lower()
      if not host:
          raise ValueError("empty server address")
      return host


  def set_nodelay(writer):
      sock = writer.get_extra_info("socket")
      if sock is not None:
          try:
              sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
          except OSError:
              pass


  async def pipe(reader, writer):
      try:
          while True:
              chunk = await reader.read(COPY_CHUNK_SIZE)
              if not chunk:
                  break
              writer.write(chunk)
              await writer.drain()
      except (ConnectionResetError, BrokenPipeError, OSError):
          pass
      finally:
          try:
              if writer.can_write_eof():
                  writer.write_eof()
          except OSError:
              pass


  def parse_host_port(spec):
      host, port_str = spec.rsplit(":", 1)
      return host.strip("[]"), int(port_str)


  async def handle_client(
      client_reader, client_writer, allowed_hosts, upstream_host, upstream_port
  ):
      peer = client_writer.get_extra_info("peername")
      peer_ip = peer[0] if peer else "unknown"
      upstream_writer = None

      try:
          buf = bytearray()
          host = None
          loop = asyncio.get_running_loop()
          deadline = loop.time() + HANDSHAKE_TIMEOUT

          while host is None:
              remaining = deadline - loop.time()
              if remaining <= 0:
                  return
              chunk = await asyncio.wait_for(
                  client_reader.read(MAX_HANDSHAKE_BYTES - len(buf) + 16),
                  timeout=remaining,
              )
              if not chunk:
                  return
              buf.extend(chunk)
              try:
                  host = extract_handshake_host(buf)
              except ValueError:
                  log(f"Dropped invalid handshake from {peer_ip}")
                  return
              if host is None and len(buf) > MAX_HANDSHAKE_BYTES + 16:
                  log(f"Dropped oversized handshake from {peer_ip}")
                  return

          if host not in allowed_hosts:
              log(f"Blocked {peer_ip} using host '{sanitize(host)}'")
              return

          upstream_reader, upstream_writer = await asyncio.wait_for(
              asyncio.open_connection(upstream_host, upstream_port),
              timeout=UPSTREAM_CONNECT_TIMEOUT,
          )
          set_nodelay(client_writer)
          set_nodelay(upstream_writer)

          upstream_writer.write(buf)
          await upstream_writer.drain()

          t1 = asyncio.create_task(pipe(client_reader, upstream_writer))
          t2 = asyncio.create_task(pipe(upstream_reader, client_writer))
          await asyncio.gather(t1, t2)
      except (asyncio.TimeoutError, ConnectionError, OSError):
          pass
      finally:
          if upstream_writer is not None:
              upstream_writer.close()
              try:
                  await upstream_writer.wait_closed()
              except OSError:
                  pass
          client_writer.close()
          try:
              await client_writer.wait_closed()
          except OSError:
              pass


  async def run():
      listen_spec = os.environ.get("MC_GATE_LISTEN", "0.0.0.0:25565")
      upstream_spec = os.environ.get("MC_GATE_UPSTREAM", "127.0.0.1:25567")
      hosts_raw = os.environ.get("MC_GATE_ALLOWED_HOSTS", "")

      allowed_hosts = {
          h.strip().rstrip(".").lower()
          for h in hosts_raw.split(",")
          if h.strip()
      }
      if not allowed_hosts:
          log("MC_GATE_ALLOWED_HOSTS must list at least one hostname")
          return 2

      listen_host, listen_port = parse_host_port(listen_spec)
      upstream_host, upstream_port = parse_host_port(upstream_spec)

      server = await asyncio.start_server(
          lambda r, w: handle_client(
              r, w, allowed_hosts, upstream_host, upstream_port
          ),
          host=listen_host,
          port=listen_port,
      )
      log(
          f"Listening on {listen_host}:{listen_port} -> "
          f"{upstream_host}:{upstream_port} "
          f"(allowed: {', '.join(sorted(allowed_hosts))})"
      )
      async with server:
          await server.serve_forever()
      return 0


  if __name__ == "__main__":
      try:
          sys.exit(asyncio.run(run()))
      except KeyboardInterrupt:
          sys.exit(0)
''
