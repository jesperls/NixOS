import base64
import hashlib
from pathlib import Path
import socket
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request


def request(port, password=None):
    headers = {}
    if password is not None:
        headers['Authorization'] = 'Basic ' + base64.b64encode(('glances:' + password).encode()).decode()
    request = urllib.request.Request(f'http://127.0.0.1:{port}/api/4/cpu', headers=headers)
    try:
        with urllib.request.urlopen(request, timeout=3) as response:
            return response.status
    except urllib.error.HTTPError as error:
        return error.code


with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    credential = root / 'credentials'
    credential.mkdir(mode=0o700)
    password = 'test-only-password'
    salt = '00112233445566778899aabbccddeeff'
    first = hashlib.pbkdf2_hmac('sha256', password.encode(), b'', 100000, dklen=128).hex()
    hashed = hashlib.pbkdf2_hmac('sha256', first.encode(), salt.encode(), 100000, dklen=128).hex()
    (credential / 'glances.pwd').write_text(salt + '$' + hashed)
    args = sys.argv[1:]
    config_index = args.index('--config') + 1
    config = Path(args[config_index]).read_text()
    assert '/run/credentials/glances.service' in config
    (root / 'glances.conf').write_text(config.replace('/run/credentials/glances.service', str(credential)))
    args[config_index] = str(root / 'glances.conf')
    args[args.index('--bind') + 1] = '127.0.0.1'
    with socket.socket() as reservation:
        reservation.bind(('127.0.0.1', 0))
        port = reservation.getsockname()[1]
    with (root / 'log').open('w+') as log:
        process = subprocess.Popen(['glances', '--port', str(port)] + args,
                                   stdin=subprocess.DEVNULL, stdout=log, stderr=log)
        try:
            deadline = time.monotonic() + 30
            while True:
                try:
                    assert request(port) == 401, 'Unauthenticated API request was accepted'
                    break
                except (urllib.error.URLError, TimeoutError):
                    if process.poll() is not None or time.monotonic() > deadline:
                        log.seek(0)
                        raise AssertionError('Glances failed to start noninteractively:\n' + log.read())
                    time.sleep(0.2)
            assert request(port, 'wrong-password') == 401
            assert request(port, password) == 200
            print('Glances starts noninteractively and enforces password-file authentication')
        finally:
            process.terminate()
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
