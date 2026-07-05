{
  pkgs,
  osConfig,
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
  apps = osConfig.mySystem.defaultApps;
  gaming = osConfig.mySystem.desktop.gaming;
  layouts = osConfig.mySystem.desktop.layouts;
  autoFakeFullscreen = osConfig.mySystem.desktop.autoFakeFullscreen;
  primaryMonitor = let
    enabled = builtins.filter (m: !m.disabled) osConfig.mySystem.monitors;
  in
    if enabled != [ ] then lib.head enabled else null;
  singleWindowRatio =
    if primaryMonitor == null then
      [ 16 9 ]
    else
      let
        parts = lib.splitString "x" primaryMonitor.resolution;
      in
      [
        (layouts.centered.masterWidth * (lib.toInt (lib.elemAt parts 0)))
        (lib.toInt (lib.elemAt parts 1))
      ];
  generatedState = {
    keyboard_layout = osConfig.mySystem.system.keyboardLayout;
    lockscreen = {
      enable = lockscreen.enable;
      lock_on_boot = lockscreen.enable && lockscreen.lockOnBoot;
    };
    apps = {
      terminal = apps.terminal.command;
      browser = apps.browser.command;
      file_manager = apps.fileManager.command;
      editor = apps.editor.command;
    };
    gaming = {
      tearing = gaming.tearing.enable;
      tearing_class_patterns = gaming.tearing.classPatterns;
    };
    layouts = {
      default = layouts.default;
      cycle = layouts.cycle;
      centered = {
        master_width = layouts.centered.masterWidth;
        master_width_min = layouts.centered.masterWidthMin;
        master_width_max = layouts.centered.masterWidthMax;
        resize_step = layouts.centered.resizeStep;
      };
      single_window_ratio = singleWindowRatio;
    };
    auto_fake_fullscreen = {
      enable = autoFakeFullscreen.enable;
      classes =
        if autoFakeFullscreen.classes == [ ] then
          [ apps.browser.command ]
        else
          autoFakeFullscreen.classes;
    };
    theme = {
      active_border = activeBorder;
      border_size = theme.borders;
      gaps_in = theme.gaps.inner;
      gaps_out = theme.gaps.outer;
      inactive_border = "rgba(${lib.removePrefix "#" theme.colors.inactiveBorder}${theme.opacity.inactiveBorder})";
      rounding = theme.rounding;
      blur = {
        enabled = theme.blur.enable;
        size = theme.blur.size;
        passes = theme.blur.passes;
        xray = theme.blur.xray;
      };
      shadow_enabled = theme.shadow.enable;
      animations = {
        enabled = theme.animations.enable;
        speed = theme.animations.speed;
      };
      translucent_opacity = theme.opacity.translucent;
      translucent_apps = theme.opacity.translucentApps;
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
    "hypr/jesperls/layouts.lua".source = ./hyprland/lua/layouts.lua;
    "hypr/jesperls/layout_modes.lua".source = ./hyprland/lua/layout_modes.lua;
    "hypr/jesperls/events.lua".source = ./hyprland/lua/events.lua;
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
