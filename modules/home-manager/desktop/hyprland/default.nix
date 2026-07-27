{
  pkgs,
  osConfig,
  lib,
  inputs,
  ...
}:

let
  toLua = lib.generators.toLua { };
  lockscreen = osConfig.mySystem.desktop.lockscreen;
  theme = osConfig.mySystem.theme;
  hyprSettings = import ./settings.nix {
    inherit
      lib
      osConfig
      ;
  };
  apps = osConfig.mySystem.defaultApps;
  gaming = osConfig.mySystem.desktop.gaming;
  layouts = osConfig.mySystem.desktop.layouts;
  autoFakeFullscreen = osConfig.mySystem.desktop.autoFakeFullscreen;
  primaryMonitor =
    let
      enabled = builtins.filter (m: !m.disabled) osConfig.mySystem.monitors;
    in
    if enabled != [ ] then lib.head enabled else null;
  singleWindowRatio =
    if primaryMonitor == null then
      [
        16
        9
      ]
    else
      let
        parts = lib.splitString "x" primaryMonitor.resolution;
      in
      [
        (layouts.centered.masterWidth * (lib.toInt (lib.elemAt parts 0)))
        (lib.toInt (lib.elemAt parts 1))
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
        height_resize_step = layouts.centered.heightResizeStep;
        full_height = layouts.centered.fullHeight;
        aspect = layouts.centered.fullHeightAspect;
      };
      single_window_ratio = singleWindowRatio;
    };
    auto_fake_fullscreen = {
      enable = autoFakeFullscreen.enable;
      classes =
        if autoFakeFullscreen.classes == [ ] then [ apps.browser.command ] else autoFakeFullscreen.classes;
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
    package = null;
    portalPackage = null;
    configType = "lua";
    plugins = [
      inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    settings = hyprSettings;
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
