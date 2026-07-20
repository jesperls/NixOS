{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  lock = config.mySystem.desktop.lockscreen;
  idle = config.mySystem.desktop.idle;

  mkListener =
    timeout: onTimeout: onResume:
    { inherit timeout onTimeout; } // lib.optionalAttrs (onResume != null) { inherit onResume; };

  listeners = lib.optionals idle.enable (
    lib.optional (idle.dimTimeout > 0) (
      mkListener idle.dimTimeout "ambxst brightness ${toString idle.dimBrightness} -s" "ambxst brightness -r"
    )
    ++ lib.optional (lock.enable && idle.lockTimeout > 0) (
      mkListener idle.lockTimeout "loginctl lock-session" null
    )
    ++ lib.optional (idle.screenOffTimeout > 0) (
      mkListener idle.screenOffTimeout "ambxst screen off" "ambxst screen on"
    )
    ++ lib.optional (idle.suspendTimeout > 0) (mkListener idle.suspendTimeout "ambxst suspend" null)
  );

  idleConfig = {
    general = {
      lock_cmd = "ambxst lock";
      before_sleep_cmd = if (lock.enable && lock.lockOnSleep) then "loginctl lock-session" else "";
      after_sleep_cmd = "ambxst screen on";
    };
    inherit listeners;
  };

  integrationScript = pkgs.writeShellApplication {
    name = "ambxst-integration";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      conf="$HOME/.config/ambxst/config"
      mkdir -p "$conf"

      # Config files seeded from the nix store used to inherit its read-only
      # permissions, which silently broke saving settings.
      chmod u+w "$conf"/*.json 2>/dev/null || true

      compositor="$conf/compositor.json"
      if [ -f "$compositor" ]; then
        tmp="$compositor.tmp"
        jq '.manageKeybinds = false | .manageAutostart = false | .manageLayout = false' \
          "$compositor" > "$tmp" && mv "$tmp" "$compositor"
      else
        printf '{ "manageKeybinds": false, "manageAutostart": false, "manageLayout": false }\n' > "$compositor"
      fi

      # Idle/lock behaviour is owned by NixOS (mySystem.desktop.idle +
      # mySystem.desktop.lockscreen). Assert it into system.json so Ambxst's
      # built-in idle daemon can't lock the screen when the lockscreen is off.
      system="$conf/system.json"
      idle=${lib.escapeShellArg (builtins.toJSON idleConfig)}
      if [ -f "$system" ]; then
        tmp="$system.tmp"
        jq --argjson idle "$idle" '.idle = $idle' "$system" > "$tmp" && mv "$tmp" "$system"
      else
        jq -n --argjson idle "$idle" '{idle: $idle}' > "$system"
      fi
    '';
  };
in
{
  imports = [ inputs.ambxst.nixosModules.default ];

  programs.ambxst.systemd.enable = true;

  systemd.user.services.ambxst.serviceConfig.ExecStartPre = lib.getExe integrationScript;

  environment.systemPackages = [ pkgs.linux-wallpaperengine ];
}
