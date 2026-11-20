import socket
import struct
import subprocess
import sys
import threading
import time


GATE_BIN = sys.argv[1]


def encode_varint(value):
    out = bytearray()
    while True:
        part = value & 0x7F
        value >>= 7
        if value:
            out.append(part | 0x80)
        else:
            out.append(part)
            return bytes(out)


def make_handshake(host, port=25565, proto=767, next_state=1):
    host_bytes = host.encode("utf-8")
    payload = (
        encode_varint(0)
        + encode_varint(proto)
        + encode_varint(len(host_bytes))
        + host_bytes
        + struct.pack(">H", port)
        + encode_varint(next_state)
    )
    return encode_varint(len(payload)) + payload


def pick_free_port():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(("127.0.0.1", 0))
        return s.getsockname()[1]


def start_echo_upstream(port, received):
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind(("127.0.0.1", port))
    srv.listen(8)
    stop = threading.Event()

    def accept_loop():
        srv.settimeout(0.2)
        while not stop.is_set():
            try:
                conn, _ = srv.accept()
            except socket.timeout:
                continue
            except OSError:
                break
            with conn:
                conn.settimeout(2.0)
                data = conn.recv(4096)
                received.append(data)
                conn.sendall(b"OK:" + data)

    thread = threading.Thread(target=accept_loop, daemon=True)
    thread.start()
    return srv, stop


def wait_port(port):
    deadline = time.monotonic() + 5
    while time.monotonic() < deadline:
        try:
            with socket.create_connection(("127.0.0.1", port), timeout=0.2):
                return
        except OSError:
            time.sleep(0.05)
    raise RuntimeError(f"port {port} did not open")


def send_and_recv(port, data):
    with socket.create_connection(("127.0.0.1", port), timeout=2.0) as sock:
        sock.settimeout(2.0)
        sock.sendall(data)
        sock.shutdown(socket.SHUT_WR)
        chunks = []
        while True:
            try:
                part = sock.recv(4096)
            except ConnectionResetError:
                break
            if not part:
                break
            chunks.append(part)
        return b"".join(chunks)


def main():
    upstream_port = pick_free_port()
    gate_port = pick_free_port()
    received = []
    srv, stop = start_echo_upstream(upstream_port, received)

    env = {
        "PATH": "/bin:/usr/bin",
        "MC_GATE_LISTEN": f"127.0.0.1:{gate_port}",
        "MC_GATE_UPSTREAM": f"127.0.0.1:{upstream_port}",
        "MC_GATE_ALLOWED_HOSTS": "bonecontrol.com",
    }
    proc = subprocess.Popen(
        [GATE_BIN],
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    try:
        wait_port(gate_port)

        assert send_and_recv(gate_port, make_handshake("1.2.3.4")) == b""
        assert send_and_recv(gate_port, make_handshake("evil.example.com")) == b""
        assert send_and_recv(gate_port, b"GET / HTTP/1.1\r\nHost: x\r\n\r\n") == b""
        assert received == [], f"blocked clients reached upstream: {received}"

        vanilla = make_handshake("bonecontrol.com", next_state=1) + b"\x01\x00"
        assert send_and_recv(gate_port, vanilla) == b"OK:" + vanilla

        neoforge = make_handshake("BoneControl.com.\x00FML3\x00", next_state=2) + b"LOGIN"
        assert send_and_recv(gate_port, neoforge) == b"OK:" + neoforge

        assert received == [vanilla, neoforge]
    finally:
        proc.terminate()
        try:
            proc.wait(timeout=3)
        except subprocess.TimeoutExpired:
            proc.kill()
        stop.set()
        srv.close()


if __name__ == "__main__":
    main()
