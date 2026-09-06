{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mySystem.performance.autofdo;
in
{
  options.mySystem.performance.autofdo = {
    enable = lib.mkEnableOption "periodic system-wide AutoFDO profile collection";

    interval = lib.mkOption {
      type = lib.types.str;
      default = "1h";
      description = "How often to sample, in systemd time units.";
    };

    duration = lib.mkOption {
      type = lib.types.str;
      default = "5m";
      description = "Length of each sampling window, in coreutils sleep units.";
    };

    samplePeriod = lib.mkOption {
      type = lib.types.str;
      default = "500009";
      description = "perf event period; prime numbers avoid sampling lockstep.";
    };

    minCpuLoad = lib.mkOption {
      type = lib.types.nullOr lib.types.float;
      default = 0.25;
      description = "Profile only when the 1-min load average reaches this fraction of CPU cores busy; null always profiles.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.timers.autofdo-collector = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "10m";
        OnUnitActiveSec = cfg.interval;
        Persistent = true;
      };
    };

    systemd.services.autofdo-collector = {
      path = [
        pkgs.perf
        pkgs.autofdo
        pkgs.coreutils
        pkgs.gawk
      ];
      serviceConfig = {
        Type = "oneshot";
        StateDirectory = "autofdo";
        RuntimeDirectory = "autofdo";
        UMask = "0077";
      };
      script = ''
        set -e

        # Gate: skip when the desktop is (mostly) idle so profiles capture real work
        ${lib.optionalString (cfg.minCpuLoad != null) ''
          load=$(cut -d' ' -f1 /proc/loadavg)
          threshold=$(awk -v l=${toString cfg.minCpuLoad} -v c="$(nproc)" 'BEGIN { printf "%.1f", l * c }')
          if awk -v l="$load" -v t="$threshold" 'BEGIN { exit !(l < t) }'; then
            echo "autofdo: 1-min load $load below $threshold, skipping"
            exit 0
          fi
        ''}

        if [ "$(uname -r)" != ${lib.escapeShellArg config.boot.kernelPackages.kernel.modDirVersion} ]; then
          echo "autofdo: running kernel differs from the configured kernel; reboot before collecting" >&2
          exit 0
        fi

        timestamp=$(date +%s)
        raw="$RUNTIME_DIRECTORY/perf.data"
        profile="$STATE_DIRECTORY/profile-$timestamp.afdo"
        trap 'rm -f "$raw" "$raw.old" "$profile.tmp"' EXIT
        vmlinux=${config.boot.kernelPackages.kernel.dev}/vmlinux

        if [ ! -f "$vmlinux" ]; then
          echo "autofdo: vmlinux not found at $vmlinux; kernel package doesn't ship it" >&2
          exit 0
        fi

        # AMD Zen5 (amd_lbr_v2): taken-branch sampling + branch stack. The kernel
        # docs' --pfm-events name isn't in nixpkgs' libpfm4, branches:k is equivalent.
        perf record -e branches:k \
          -a -N -b -c ${lib.escapeShellArg cfg.samplePeriod} -o "$raw" -- sleep ${lib.escapeShellArg cfg.duration}

        create_llvm_prof \
          --binary="$vmlinux" \
          --profile="$raw" \
          --format=extbinary \
          --out="$profile.tmp"

        chmod 644 "$profile.tmp"
        mv "$profile.tmp" "$profile"
      '';
    };
  };
}
