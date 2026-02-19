import logging
import os
import shlex
import socket
import subprocess


LOG_LEVEL = os.environ.get("BONECONTROL_LOG_LEVEL", "INFO").upper()
LISTEN_HOST = os.environ.get("BONECONTROL_LISTEN_HOST", "0.0.0.0")
LISTEN_PORT = int(os.environ.get("BONECONTROL_PORT", "12345"))
BUFFER_SIZE = int(os.environ.get("BONECONTROL_BUFFER_SIZE", "4096"))

POWEROFF_COMMAND = os.environ.get("BONECONTROL_POWEROFF_COMMAND", "poweroff")
TOASTER_COMMAND = os.environ.get(
    "BONECONTROL_TOASTER_COMMAND",
    "caelestia-shell ipc --any-display call toaster info",
)
TOASTER_TITLE = os.environ.get("BONECONTROL_TOASTER_TITLE", "Remote message")
TOASTER_ICON = os.environ.get("BONECONTROL_TOASTER_ICON", "chat")


def run_command(command: str, extra_args: list[str] | None = None) -> None:
    parts = shlex.split(command)
    if extra_args:
        parts.extend(extra_args)

    try:
        subprocess.run(parts, check=False)
    except OSError as err:
        logging.exception("Failed to run command %s: %s", parts, err)


def handle_payload(payload: str) -> None:
    data = payload.strip()
    if not data:
        return

    if data == "2":
        logging.info("Received action 2: powering off machine")
        run_command(POWEROFF_COMMAND)
        return

    if data.startswith("m,"):
        message = data[2:].strip()
        if not message:
            return

        logging.info("Received action 9 message, forwarding to Caelestia toaster")
        run_command(TOASTER_COMMAND, [TOASTER_TITLE, message, TOASTER_ICON])
        return

    logging.info("Received unhandled payload: %s", data)


def main() -> None:
    logging.basicConfig(
        level=getattr(logging, LOG_LEVEL, logging.INFO),
        format="%(asctime)s [%(levelname)s] %(message)s",
    )

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server:
        server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        server.bind((LISTEN_HOST, LISTEN_PORT))
        server.listen(16)

        logging.info("BoneControl listener started on %s:%s", LISTEN_HOST, LISTEN_PORT)

        while True:
            conn, addr = server.accept()
            with conn:
                try:
                    conn.settimeout(2.0)

                    chunks: list[bytes] = []
                    while True:
                        chunk = conn.recv(BUFFER_SIZE)
                        if not chunk:
                            break
                        chunks.append(chunk)

                    payload = b"".join(chunks).decode("utf-8", errors="replace")
                    logging.debug("Received payload from %s: %r", addr, payload)
                    handle_payload(payload)
                except OSError:
                    logging.exception("Failed to process connection from %s", addr)


if __name__ == "__main__":
    main()
