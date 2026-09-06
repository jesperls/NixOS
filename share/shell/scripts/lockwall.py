#!/usr/bin/env python3
import argparse
import hashlib
from pathlib import Path

from media_cache import current, frame_command, render_atomic


def generate(source_path, cache):
    source = Path(source_path).expanduser()
    if source.suffix.lower() not in {'.mp4', '.webm', '.mov', '.avi', '.mkv', '.gif'}:
        return
    destination = Path(cache) / 'lockscreen' / (hashlib.md5(source_path.encode()).hexdigest() + '.jpg')
    if not current(source, destination):
        render_atomic(frame_command(source), destination, 30)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('wallpaper')
    parser.add_argument('cache')
    args = parser.parse_args()
    generate(args.wallpaper, args.cache)


if __name__ == '__main__':
    main()
