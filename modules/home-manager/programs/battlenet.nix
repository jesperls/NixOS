{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = config.programs.battlenet;

  battlenet = pkgs.writeShellScriptBin "battlenet" ''
    : "''${WINEPREFIX:=${lib.escapeShellArg cfg.prefix}}"
    : "''${GAMEID:=battlenet}"
    : "''${PROTONPATH:=${lib.escapeShellArg cfg.protonPath}}"
    export WINEPREFIX GAMEID PROTONPATH
    ${lib.optionalString osConfig.mySystem.hardware.nvidia.enable "export PROTON_ENABLE_NVAPI=1"}

    exec ${lib.getExe pkgs.umu-launcher} \
      "$WINEPREFIX/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe" "$@"
  '';
in
{
  options.programs.battlenet = {
    prefix = lib.mkOption {
      type = lib.types.str;
      description = "Wine prefix containing the Battle.net installation.";
    };

    protonPath = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.proton-ge-bin.steamcompattool}";
      defaultText = lib.literalExpression ''"''${pkgs.proton-ge-bin.steamcompattool}"'';
      description = "Proton build used to run Battle.net.";
    };
  };

  config = {
    home.packages = [ battlenet ];

    xdg.desktopEntries.battlenet = {
      name = "Battle.net";
      exec = "${battlenet}/bin/battlenet";
      icon = "applications-games";
      categories = [ "Game" ];
    };
  };
}
