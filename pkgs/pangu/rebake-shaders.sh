#!/usr/bin/env bash
# Re-bake .qsb shader bundles from their .frag/.vert sources. The runtime
# loads the .qsb directly and the nix build never regenerates them, so after
# editing a shader you must run this or the change is silently inert.
#
#   nix shell nixpkgs#qt6.qtshadertools -c bash pkgs/pangu/rebake-shaders.sh
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../share/shell" && pwd)"

command -v qsb >/dev/null 2>&1 || {
    echo "qsb not found on PATH — try: nix shell nixpkgs#qt6.qtshadertools" >&2
    exit 1
}

while IFS= read -r src; do
    qsb "$src" -o "${src}.qsb"
done < <(find "$root" \( -name '*.frag' -o -name '*.vert' \) | sort)
