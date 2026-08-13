# Manual AutoFDO for the CachyOS kernel

The kernel can be compiled with Clang AutoFDO (profile-guided optimization):
a hardware-sampled profile of *your actual workload* is fed back into the
compiler so hot kernel paths get optimized for how *you* use the machine.
The `autofdo = true` build you started from only turns on the profiling
config (split machine functions + profiling debug info); applying a real
profile is what this workflow is for.

It's a multi-day loop:

```
collect (hourly timer) ──▶ merge profiles ──▶ rebuild kernel with profile
```

## How it works

Zen 5 (`amd_lbr_v2`) supports taken-branch sampling. Every hour the
`autofdo-collector` service runs:

1. `perf record -e branches:k -a -N -b -c 500009` for 5 minutes, sampling
   kernel branches on all CPUs while you use the machine normally
2. `create_llvm_prof` converts the raw `perf.data` against the *running*
   kernel's unstripped `vmlinux` (`config.boot.kernelPackages.kernel.dev/vmlinux`)
   into an `extbinary` profile
3. profiles land in `/var/lib/autofdo/profile-<ts>.afdo`, the raw data is deleted

After a few days you merge them and rebuild the kernel with the merged
profile via `CLANG_AUTOFDO_PROFILE`.

## Components

| File | What |
| ---- | ---- |
| `pkgs/autofdo/default.nix` | Google's prebuilt static `create_llvm_prof` v0.30.1 |
| `modules/nixos/performance/autofdo.nix` | The collector timer + service + `perf` sysctls |
| `modules/nixos/options/performance.nix` | `performance.kernel.autofdo` (bool or profile path) |
| `hosts/pangu/configuration.nix` | Collection enabled here |

## Workflow

### 1. Collect

Collection is already enabled (`performance.autofdo.enable = true`). Rebuild
and reboot, then just use the machine normally for a few days — builds,
gaming, VMs, whatever you want the kernel optimized for.

```bash
snis                        # rebuild + switch
systemctl list-timers autofdo-collector
systemctl status autofdo-collector   # after the first run
journalctl -u autofdo-collector      # if something failed
ls /var/lib/autofdo/                 # accumulated profiles
```

### 2. Merge

```bash
nix shell nixpkgs#llvmPackages_18.llvm -c \
  llvm-profdata merge --sample -o merged.afdo /var/lib/autofdo/profile-*.afdo
```

### 3. Apply the profile

Copy the merged profile into the repo and point the kernel at it:

```nix
# hosts/pangu/configuration.nix
performance.kernel.autofdo = ./profiles/merged.afdo;   # was: autofdo = true
```

The path must be a Nix path (in the repo), not a string — `mkCachyKernel`
checks `builtins.isPath` to decide whether to set `CLANG_AUTOFDO_PROFILE`.

### 4. Rebuild and benchmark

```bash
snis
```

The rebuild will take a while (no binary cache for a customized kernel; a
profile application is always a local build). Boot it and benchmark against
your baseline run. `performance.kernel.autofdo = true` again to get back the
non-profile AutoFDO build, or `false`/remove the whole `kernel` block to fall
back to the cached `linuxPackages-cachyos-latest-lto`.

### 5. When done

```nix
# hosts/pangu/configuration.nix
performance.autofdo.enable = false;
```

This stops the timer and drops the two sysctls. The compiled profile stays
baked into the running kernel until you rebuild.

## Options

| Option | Meaning |
| ------ | ------- |
| `performance.kernel.processorOpt` | Microarch the kernel is compiled for (`zen4` covers Zen 5). Default `null` → `x86_64-v1` so untouched options still hit the pinned binary cache. |
| `performance.kernel.autofdo` | `false` off · `true` profiling config only · `<repo path>` applies that profile |
| `performance.kernel.performanceGovernor` | Default cpufreq governor = performance |
| `performance.kernel.bbr3` | BBRv3 as default TCP congestion control |
| `performance.autofdo.enable` | Turn the collector timer on/off |
| `performance.autofdo.interval` | Sampling frequency (`1h` default) |
| `performance.autofdo.duration` | Window length (`5m` default) |
| `performance.autofdo.samplePeriod` | `perf` event period (`500009` default) |
| `performance.autofdo.minCpuLoad` | Profile only when the 1-min load average reaches this fraction of cores busy (`0.25` default, `null` always profiles) |
