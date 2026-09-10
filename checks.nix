{
  lib,
  pkgs,
  hosts,
  overlays,
}:

let
  pangu = (pkgs.extend overlays).pangu;

  generatedLua =
    pkgs.writeText "generated.lua"
      hosts.pangu.config.home-manager.users.${hosts.pangu.config.mySystem.user.username}.xdg.configFile."hypr/pangu/generated.lua".text;
in
lib.mapAttrs' (
  hostName: host: lib.nameValuePair "${hostName}-system" host.config.system.build.toplevel
) hosts
// {
  shell-settings = import ./tests/shell-settings.nix {
    inherit lib pkgs;
    host = hosts.pangu;
  };

  hyprland-lua = pkgs.runCommand "hyprland-lua-check" { nativeBuildInputs = [ pkgs.lua ]; } ''
    lua ${./tests/hyprland.lua} ${./share/hypr}
    touch "$out"
  '';

  hyprland-contract =
    pkgs.runCommand "hyprland-generated-contract"
      {
        nativeBuildInputs = [ pkgs.lua ];
      }
      ''
        lua ${./tests/hyprland_contract.lua} ${generatedLua}
        touch "$out"
      '';

  pangu-runtime =
    pkgs.runCommand "pangu-runtime-check"
      {
        nativeBuildInputs = [
          pkgs.bash
          pkgs.coreutils
          pkgs.gnused
        ];
      }
      ''
        runtimePath=$(sed -n 's/^export PATH="\(.*\):\$PATH"$/\1/p' ${pangu}/bin/pangu | head -1)
        [ -n "$runtimePath" ] || { echo "pangu: could not read the wrapper PATH" >&2; exit 1; }
        export PATH="$runtimePath"
        for cmd in bash find python3 jq grep sed awk pkill pgrep hypridle gtk-launch \
          xdg-terminal-exec matugen mpvpaper grim slurp wl-copy ddcutil brightnessctl \
          tesseract zbarimg swappy notify-send; do
          command -v "$cmd" >/dev/null || { echo "pangu runtime is missing: $cmd" >&2; exit 1; }
        done
        touch "$out"
      '';
}
