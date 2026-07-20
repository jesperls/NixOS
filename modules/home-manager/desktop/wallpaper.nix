{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  lweSrc = inputs.linux-wallpaper-engine;
  lwePkgs = import inputs.nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowInsecurePredicate = p: lib.getName p == "electron";
  };

  linux-wallpaper-engine = lwePkgs.callPackage "${lweSrc}/distro/nix/package.nix" {
    src = lweSrc;
    package = lib.importJSON "${lweSrc}/package.json";
    electron = lwePkgs.electron_39;
    bun2nix = lweSrc.inputs.bun2nix.packages.${pkgs.stdenv.hostPlatform.system}.bun2nix;
  };
in
{
  home.packages = [ linux-wallpaper-engine ];

  wayland.windowManager.hyprland.settings.on = [
    {
      _args = [
        "hyprland.start"
        (lib.generators.mkLuaInline ''
          function()
            hl.exec_cmd("linux-wallpaper-engine")
          end
        '')
      ];
    }
  ];
}
