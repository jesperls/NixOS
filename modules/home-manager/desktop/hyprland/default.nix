{
  config,
  osConfig,
  lib,
  ...
}:

let
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
  input = osConfig.mySystem.desktop.input;
  generatedState = {
    shell = osConfig.mySystem.desktop.shell.enable;
    monitors = {
      inherit (hyprlandConfig) primary;
      primary_workspaces = hyprlandConfig.primaryWorkspaces;
    };
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
      translucent_apps =
        if osConfig.mySystem.desktop.shell.enable then [ ] else theme.opacity.translucentApps; # Pangu's gtk.css already sets background alpha without dimming text.
      font_family = theme.fonts.sans;
    };
  };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    settings = hyprlandConfig.settings;
    systemd.variables = lib.unique (
      [
        "DISPLAY"
        "HYPRLAND_INSTANCE_SIGNATURE"
        "WAYLAND_DISPLAY"
        "XDG_CURRENT_DESKTOP"
        "XDG_SESSION_TYPE"
        "HYPRCURSOR_THEME"
        "HYPRCURSOR_SIZE"
      ]
      ++ builtins.attrNames config.home.sessionVariables
    );
    xdph.settings.screencopy.allow_token_by_default = true;
  };

  programs.pangu.hyprland.preset = {
    enable = osConfig.mySystem.desktop.shell.enable;
    settings = generatedState;
  };
}
