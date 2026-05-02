{
  pkgs,
  osConfig,
  ...
}:

let
  hyprlandTarget = "hyprland-session.target";

  commonUnit = {
    After = [ hyprlandTarget ];
    PartOf = [ hyprlandTarget ];
  };

  commonInstall = {
    WantedBy = [ hyprlandTarget ];
  };

  cursorSize = builtins.toString osConfig.mySystem.theme.gtk.cursorTheme.size;
  cursorTheme = osConfig.mySystem.theme.gtk.cursorTheme.name;

  graphicalEnv = [
    "XCURSOR_THEME=${cursorTheme}"
    "XCURSOR_SIZE=${cursorSize}"
    "HYPRCURSOR_THEME=${cursorTheme}"
    "HYPRCURSOR_SIZE=${cursorSize}"
  ];
in
{
  systemd.user.services = {
    solaar = {
      Unit = commonUnit // {
        Description = "Solaar — Logitech device manager";
      };
      Service = {
        ExecStart = "${pkgs.solaar}/bin/solaar -w hide";
        Restart = "on-failure";
        RestartSec = 2;
        Environment = graphicalEnv;
      };
      Install = commonInstall;
    };

    qpwgraph = {
      Unit = commonUnit // {
        Description = "qpwgraph — PipeWire graph (minimized)";
        After = commonUnit.After ++ [ "pipewire.service" ];
      };
      Service = {
        ExecStart = "${pkgs.qpwgraph}/bin/qpwgraph -m";
        Restart = "on-failure";
        RestartSec = 2;
        Environment = graphicalEnv;
      };
      Install = commonInstall;
    };

    cliphist-text = {
      Unit = commonUnit // {
        Description = "cliphist — watch text clipboard, store in history";
      };
      Service = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install = commonInstall;
    };

    cliphist-image = {
      Unit = commonUnit // {
        Description = "cliphist — watch image clipboard, store in history";
      };
      Service = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install = commonInstall;
    };

    hyprpolkitagent = {
      Unit = commonUnit // {
        Description = "hyprpolkitagent — polkit authentication agent";
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
        Slice = "session.slice";
        TimeoutStopSec = "5sec";
        Restart = "on-failure";
      };
      Install = commonInstall;
    };
  };
}
