{
  pkgs,
  osConfig,
  lib,
  ...
}:

let
  toLua = lib.generators.toLua { };
  theme = osConfig.mySystem.theme;
  hyprlandConfig = import ./settings.nix {
    inherit
      lib
      osConfig
      ;
  };
  apps = osConfig.mySystem.defaultApps;
  tearing = osConfig.mySystem.desktop.tearing;
  layouts = osConfig.mySystem.desktop.layouts;
  autoFakeFullscreen = osConfig.mySystem.desktop.autoFakeFullscreen;
  primaryMonitor =
    if hyprlandConfig.activeMonitors == [ ] then null else lib.head hyprlandConfig.activeMonitors;
  singleWindowRatio =
    if primaryMonitor == null then
      [
        16
        9
      ]
    else
      [
        (layouts.centered.masterWidth * hyprlandConfig.monitorWidth primaryMonitor)
        (lib.toInt (lib.elemAt (lib.splitString "x" primaryMonitor.resolution) 1))
      ];
  input = osConfig.mySystem.desktop.input;
  generatedState = {
    shell = osConfig.mySystem.desktop.shell.enable;
    keyboard_layout = osConfig.mySystem.system.keyboardLayout;
    input = {
      accel_profile = input.accelProfile;
      repeat_rate = input.repeatRate;
      repeat_delay = input.repeatDelay;
      numlock = input.numlockByDefault;
    };
    render = {
      direct_scanout = osConfig.mySystem.desktop.render.directScanout;
    };
    apps = {
      terminal = apps.terminal.command;
      browser = apps.browser.command;
      file_manager = apps.fileManager.command;
      editor = apps.editor.command;
    };
    tearing = {
      enable = tearing.enable;
      class_patterns = tearing.classPatterns;
    };
    layouts = {
      default = layouts.default;
      cycle = layouts.cycle;
      centered = {
        master_width = layouts.centered.masterWidth;
        height_resize_step = layouts.centered.heightResizeStep;
        full_height = layouts.centered.fullHeight;
        aspect = layouts.centered.fullHeightAspect;
      };
      single_window_ratio = singleWindowRatio;
    };
    auto_fake_fullscreen = {
      enable = autoFakeFullscreen.enable;
      classes =
        if autoFakeFullscreen.classes == [ ] then
          [ (lib.removeSuffix ".desktop" apps.browser.desktopFile) ]
        else
          autoFakeFullscreen.classes;
    };
    theme = {
      animations = {
        enabled = theme.animations.enable;
        speed = theme.animations.speed;
      };
      translucent_opacity = theme.opacity.translucent;
      translucent_apps = theme.opacity.translucentApps;
      font_family = theme.fonts.sans;
    };
  };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    settings = hyprlandConfig.settings;
    extraConfig = ''
      require("pangu.init")
    '';
  };

  xdg.configFile = {
    "hypr/pangu" = {
      source = ../../../../share/hypr;
      recursive = true;
    };
    "hypr/pangu/generated.lua".text = "return ${toLua generatedState}\n";
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
