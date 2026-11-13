{
  config,
  lib,
  pkgs,
  ...
}:

let
  hyprlandSession = pkgs.writeShellScript "hyprland-session" ''
    # greetd runs /bin/sh -c without login profile scripts.
    if [ -f /etc/profile ]; then
      . /etc/profile
    fi
    if [ -f "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]; then
      . "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
    elif [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    fi

    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=Hyprland
    export XDG_SESSION_DESKTOP=Hyprland

    # Keep compositor logs off tty1 while useTextGreeter owns the VT.
    exec ${pkgs.systemd}/bin/systemd-cat --identifier=hyprland ${config.programs.hyprland.package}/bin/start-hyprland
  '';
in
{
  security.polkit.enable = true;

  programs.hyprland.enable = true;

  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      default_session = {
        command = lib.escapeShellArgs [
          (lib.getExe pkgs.tuigreet)
          "--time"
          "--remember"
          "--asterisks"
          "--user-menu"
          "--theme"
          "border=darkgray;text=white;prompt=cyan;time=darkgray;action=lightcyan;button=cyan;container=black;input=white"
          "--cmd"
          "${hyprlandSession}"
        ];
        user = "greeter";
      };
    }
    // lib.optionalAttrs config.mySystem.system.autoLogin {
      initial_session = {
        command = "${hyprlandSession}";
        user = config.mySystem.user.username;
      };
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.AppChooser" = [
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [
          "gtk"
        ];
      };
    };
  };

  environment.systemPackages = [ pkgs.pamixer ];
}
