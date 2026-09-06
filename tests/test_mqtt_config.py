import os
import pathlib
import subprocess
import sys
import tempfile
import tomllib

with tempfile.TemporaryDirectory() as directory:
    env = {**os.environ, "HOME": directory, "XDG_CONFIG_HOME": directory}
    config = pathlib.Path(directory) / "go-hass-agent/preferences.toml"
    config.parent.mkdir()
    config.write_text('''[hass]
server = "http://registered-home-assistant:8123"
token = "test-registration-token"
[mqtt]
enabled = true
server = "tcp://old-broker:1883"
user = "old-user"
password = "old-password"
''')
    registration = tomllib.loads(config.read_text())["hass"]
    for script, enabled in [(sys.argv[1], True), (sys.argv[2], False), (sys.argv[1], True)]:
        result = subprocess.run([script], env=env, capture_output=True, text=True, timeout=30)
        assert result.returncode == 0, result.stderr
        saved = tomllib.loads(config.read_text())
        assert saved["hass"] == registration
        assert saved["mqtt"]["enabled"] is enabled
        assert not saved["mqtt"].get("user")
        assert not saved["mqtt"].get("password")
        if enabled:
            assert saved["mqtt"]["server"] == "tcp://test-broker:1883"
        else:
            assert not saved["mqtt"].get("server")
    before = config.read_bytes()
    result = subprocess.run([sys.argv[3]], env=env, capture_output=True, text=True, timeout=30)
    assert result.returncode != 0
    assert config.read_bytes() == before
