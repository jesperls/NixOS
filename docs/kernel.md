# Kernel and AutoFDO

Pangu imports [kernel.nix](../modules/nixos/performance/kernel.nix), which uses
the pinned CachyOS LTO kernel. With the default build options it selects the
cached package. Changing the processor target, governor, BBR3 or AutoFDO
options selects a custom kernel build. The `fallback` boot specialisation uses
the stock NixOS kernel with sched_ext disabled.

## Enable profiling

Pangu imports [autofdo.nix](../modules/nixos/performance/autofdo.nix), so its
collector timer is enabled. The kernel's AutoFDO option is currently `false`;
enable profiling before collecting samples intended for this workflow:

```nix
mySystem.performance.kernel.autofdo = true;
```

Build, activate with `snis`, then reboot into that kernel. `true` enables the
profiling build configuration; it does not apply a workload profile.

The collector runs as root, normally every hour for five minutes. It records
kernel branches with `perf`, converts them against the configured kernel's
unstripped `vmlinux`, and writes completed profiles to `/var/lib/autofdo`.
Raw samples and incomplete outputs are removed when the service exits.

```sh
systemctl list-timers autofdo-collector.timer
systemctl status autofdo-collector.service
journalctl -u autofdo-collector.service -b
ls /var/lib/autofdo/
```

Collection is skipped when the load is below its threshold, `vmlinux` is
missing, or the running kernel release differs from the configured one.
The release check requires a reboot after a kernel-changing switch; it does
not distinguish different builds with the same kernel release.
`mySystem.performance.autofdo` exposes `interval`, `duration`, `samplePeriod`
and `minCpuLoad`. Pangu sets the load threshold to `0.1` times the CPU count;
`null` disables that threshold.

## Apply a workload profile

Collect while running the workloads you want to optimise, then merge the
profiles from the repo root:

```sh
mkdir -p hosts/pangu/profiles
nix shell --inputs-from . nixpkgs#llvmPackages.llvm -c \
  llvm-profdata merge --sample \
  -o hosts/pangu/profiles/merged.afdo /var/lib/autofdo/profile-*.afdo
git add hosts/pangu/profiles/merged.afdo
```

Set this in `hosts/pangu/configuration.nix`:

```nix
mySystem.performance.kernel.autofdo = ./profiles/merged.afdo;
```

Use a Nix path, not a quoted string, and add the profile to Git so the flake
includes it. Build `.#checks.x86_64-linux.pangu-system`, activate with `snis`,
then reboot and compare the same workload against a baseline. A profile changes
the kernel derivation; expect a local build if it is not cached.

Set `autofdo = true` to return to the profiling-only build, or `false` to
disable AutoFDO. The cached kernel is selected when all kernel build options
are back at their defaults. Remove the `performance/autofdo.nix` import to
stop collection; this does not remove the profile from an already built kernel.
