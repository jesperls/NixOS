import pathlib
import subprocess
import sys
import tempfile


activation = pathlib.Path(sys.argv[1]).read_text()
original_home = sys.argv[2]
assert original_home in activation

with tempfile.TemporaryDirectory() as root:
    home = pathlib.Path(root) / "home"
    cache = home / ".var/app/example/cache/fontconfig"
    marker = home / ".local/state/flatpak/fonts"
    script = activation.replace(original_home, str(home))
    assert original_home not in script

    def activate():
        subprocess.run(["bash", "-e", "-c", 'run() { "$@"; }\n' + script], check=True)

    cache.mkdir(parents=True)
    (cache / "sentinel").write_text("cached")
    activate()
    assert not cache.exists() and marker.is_file()
    assert marker.stat().st_mode & 0o777 == 0o600
    state = marker.read_text()

    cache.mkdir(parents=True)
    (cache / "sentinel").write_text("cached")
    activate()
    assert (cache / "sentinel").read_text() == "cached"

    marker.write_text("previous font configuration")
    activate()
    assert not cache.exists() and marker.read_text() == state
