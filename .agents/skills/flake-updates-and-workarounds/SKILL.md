---
name: flake-updates-and-workarounds
description: >-
  Guides updating flake inputs, diagnosing nixpkgs or home-manager evaluation
  and build failures (such as snus or nix flake update breakages), and auditing
  or pruning hardware and package workarounds without breaking load-bearing
  fixes. Use when updating flake.lock, fixing upstream breakages, or reviewing
  workarounds.
---

# Flake Updates & Workaround Auditing

## 1. Updating Flake Inputs Safely

- Update a single input when pulling targeted upstream changes:
  ```sh
  nix flake update pangu-shell
  ```
- Update all inputs when refreshing the lockfile:
  ```sh
  nix flake update
  ```
- Never run `snus` (it runs `nh os switch --update` and activates the system). Always update `flake.lock`, fix breakages, and verify builds without switching.

## 2. Diagnosing `nixpkgs` / `home-manager` Breakages

When an input bump fails evaluation or build:

1. Reproduce with a full trace on the failing target:
   ```sh
   nix eval .#nixosConfigurations.pangu.config.system.build.toplevel.drvPath --show-trace
   nix eval .#nixosConfigurations.gonggong.config.system.build.toplevel.drvPath --show-trace
   ```
2. Inspect the exact locked upstream expression instead of guessing:
   ```sh
   NIXPKGS=$(nix eval --raw --impure --expr '(builtins.getFlake (toString ./.)).inputs.nixpkgs.outPath')
   HM=$(nix eval --raw --impure --expr '(builtins.getFlake (toString ./.)).inputs.home-manager.outPath')
   ```
   Read the upstream `package.nix` or module definition under `$NIXPKGS` or `$HM` (for example, when `override` arguments rename like `ffmpeg` -> `ffmpeg_9`, or module options migrate).
3. Check whether an existing local override in `pkgs/` or `modules/` was compensating for an upstream issue that has since been fixed or restructured.

## 3. Auditing & Pruning Workarounds

Before removing or altering any workaround, consult [references/active-traps.md](./references/active-traps.md) to distinguish **temporary upstream build fixes** from **load-bearing hardware, kernel, PipeWire, and Wayland invariants**.

### Safe Removal Checklist
1. Confirm in `$NIXPKGS` / `$HM` / `$PANGU` source that the upstream bug, header path, udev rule, or module option is genuinely resolved in the locked revision.
2. Check both hosts (`pangu` and `gonggong`) for downstream assumptions (group memberships, assertions, systemd unit ordering).
3. Update [docs/configuration.md](../../../docs/configuration.md) or [docs/desktop.md](../../../docs/desktop.md) if the workaround was mentioned there.
4. Do **not** leave tombstone comments explaining what was removed.
5. Verify formatting and build all checks across both hosts:
   ```sh
   nix fmt && nix fmt -- --ci
   nix flake check -L
   nix build --no-link .#checks.x86_64-linux.pangu-system .#checks.x86_64-linux.gonggong-system
   ```
