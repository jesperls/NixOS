{
  lib,
  pkgs,
  hosts,
  inputs,
}:

let
  home = hosts.pangu.config.home-manager.users.${hosts.pangu.config.mySystem.user.username};
  generatedLua = pkgs.writeText "generated.lua" home.xdg.configFile."hypr/pangu/generated.lua".text;
  fontActivation = pkgs.writeText "flatpak-font-cache-activation" home.home.activation.clearFlatpakFontCache.data;
in
lib.mapAttrs' (
  hostName: host: lib.nameValuePair "${hostName}-system" host.config.system.build.toplevel
) hosts
// {
  desktop-contract = import ./tests/desktop-contract.nix {
    inherit lib pkgs;
  };

  hyprland-lua = inputs.pangu-shell.checks.${pkgs.stdenv.hostPlatform.system}.hyprland;

  hyprland-contract =
    pkgs.runCommand "hyprland-generated-contract" { nativeBuildInputs = [ pkgs.lua ]; }
      ''
        lua ${inputs.pangu-shell.outPath}/tests/hyprland_contract.lua ${generatedLua}
        touch "$out"
      '';

  home-manager-backups =
    pkgs.runCommand "home-manager-backup-check" { nativeBuildInputs = [ pkgs.python3 ]; }
      ''
        python3 ${./tests/test_home_manager_backups.py} ${
          lib.getExe (pkgs.callPackage ./pkgs/hm-rotating-backup.nix { })
        }
        touch "$out"
      '';

  flatpak-font-cache =
    pkgs.runCommand "flatpak-font-cache-check"
      {
        nativeBuildInputs = [
          pkgs.python3
          pkgs.coreutils
        ];
      }
      ''
        python3 ${./tests/test_flatpak_font_cache.py} ${fontActivation} ${lib.escapeShellArg home.home.homeDirectory}
        touch "$out"
      '';
}
