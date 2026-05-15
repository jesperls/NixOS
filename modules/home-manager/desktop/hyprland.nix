{
  pkgs,
  osConfig,
  config,
  lib,
  ...
}:

let
  toLua = lib.generators.toLua { };
  lockscreen = osConfig.mySystem.desktop.lockscreen;
  theme = osConfig.mySystem.theme;
  activeBorder =
    let
      c1 = lib.removePrefix "#" theme.colors.activeBorder;
      opacity = theme.opacity.activeBorder;
    in
    if theme.borderGradient.enable then
      {
        colors = [
          "rgba(${c1}${opacity})"
          "rgba(${lib.removePrefix "#" theme.borderGradient.secondColor}${opacity})"
        ];
        angle = theme.borderGradient.angle;
      }
    else
      "rgba(${c1}${opacity})";
  hyprSettings = import ./hyprland/settings.nix {
    inherit
      lib
      osConfig
      ;
  };
  generatedState = {
    keyboard_layout = osConfig.mySystem.system.keyboardLayout;
    lockscreen = {
      enable = lockscreen.enable;
      lock_on_boot = lockscreen.enable && lockscreen.lockOnBoot;
    };
    wallpaper_picker = {
      enable = config.programs.wallpaperPicker.enable;
    };
    theme = {
      active_border = activeBorder;
      border_size = theme.borders;
      gaps_in = theme.gaps.inner;
      gaps_out = theme.gaps.outer;
      inactive_border = "rgba(${lib.removePrefix "#" theme.colors.inactiveBorder}${theme.opacity.inactiveBorder})";
      rounding = theme.rounding;
    };
  };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    configType = "lua";
    settings = hyprSettings;
    extraConfig = ''
      require("jesperls.init")
    '';
  };

  xdg.configFile = {
    "hypr/jesperls/init.lua".source = ./hyprland/lua/init.lua;
    "hypr/jesperls/binds.lua".source = ./hyprland/lua/binds.lua;
    "hypr/jesperls/settings.lua".source = ./hyprland/lua/settings.lua;
    "hypr/jesperls/windowrules.lua".source = ./hyprland/lua/windowrules.lua;
    "hypr/jesperls/startup.lua".source = ./hyprland/lua/startup.lua;
    "hypr/jesperls/generated.lua".text = "return ${toLua generatedState}\n";
    "hypr/xdph.conf".text = ''
      screencopy {
        allow_token_by_default = true
      }
    '';
  };

  home.packages = with pkgs; [
    hyprpicker
  ];
}
