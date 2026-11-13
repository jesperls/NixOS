---
name: nix-module-workflow
description: >-
  Guides adding, refactoring, and verifying NixOS modules, Home Manager modules,
  host configurations (pangu and gonggong), mySystem options, Wayland user
  services, package overlays, and flake checks in nixos-config. Use when adding
  features, changing module options, editing host configs, or adding wrappers.
---

# Nix Module & Host Workflow

## 1. Decide Where Changes Belong

| Scope | Target Path | Rule |
| --- | --- | --- |
| Every NixOS host | `modules/nixos/bundle.nix` (`core/`, `performance/`, `users.nix`, `home-manager.nix`) | Shared boot, locale, networking, nix, zram/sysctl, realtime audio group |
| Every desktop NixOS host | `modules/nixos/desktop/bundle.nix` | Graphics, Hyprland, Pangu system plumbing, desktop `nix-ld` libs, fonts, audio, bluetooth |
| Opt-in NixOS hardware/service/program | `modules/nixos/{hardware,programs,services}/<name>.nix` | Explicitly imported by hosts that need it; no `enable` boilerplate unless other modules query it |
| Every Home Manager host | `modules/home-manager/bundle.nix` (`cli/`) | Zsh, Git + `gh` credential helper, SSH, CLI tools |
| Every desktop Home Manager host | `modules/home-manager/desktop/bundle.nix` | Hyprland Lua adapter, Pangu HM module, GTK/Qt/Kitty/MPV/MIME/XDG, desktop autostarts |
| Opt-in Home Manager app/service | `modules/home-manager/{programs,services}/<name>.nix` | Imported in `hosts/<host>/home.nix` |
| Cross-module shared options | `modules/nixos/options/*.nix` | `mySystem.*` options read by multiple NixOS/HM modules |
| Package wrappers / build patches | `pkgs/default.nix`, `pkgs/emulators.nix`, `pkgs/<pkg>.nix` | Overlay packages and small helper derivations |
| Single-host tuning or package list | `hosts/<host>/{configuration,home,packages,monitors,audio}.nix` | Use upstream options directly for one-liner host settings |

Update [docs/configuration.md](../../../docs/configuration.md) first whenever changing module structure or ownership boundaries.

## 2. Option & Module Conventions

- **Upstream first**: Do not wrap an upstream NixOS or Home Manager option in `mySystem` unless multiple modules coordinate on its value.
- **Option hygiene**:
  - Keep every `mkOption.description` to **one sentence**.
  - Always set `defaultText = lib.literalExpression ...` when `default` interpolates `pkgs` or `config` paths (e.g. `config.users.users.${config.mySystem.user.username}.home`).
  - Prefer narrow types (`lib.types.enum`, `lib.types.ints.positive`, `lib.types.strMatching`) over unconstrained `lib.types.str`.
  - Add cross-option invariants to [assertions.nix](../../../modules/nixos/options/assertions.nix) (for example, `mySystem.hardware.nvidia.enable` asserting `hardware/nvidia.nix` is imported).
- **Module arguments**:
  - Flake inputs arrive via `specialArgs.inputs` (NixOS) and `extraSpecialArgs.inputs` (Home Manager).
  - Home Manager modules read system options through `osConfig.mySystem` — never import `hosts/*` or test `hostName`.
- **Override priorities**:
  - `lib.mkDefault` (1000) for overridable base defaults (e.g. `boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest`).
  - `lib.mkOverride 500` in [optimizations.nix](../../../modules/nixos/performance/optimizations.nix) to beat `nixpkgs` `mkDefault` sysctls while still losing to plain host assignments (100).
  - `lib.mkForce` (50) only when intentionally replacing upstream unit lists or sandbox flags; add a 1-line inline comment if the trap is non-obvious.

## 3. Wayland Session User Services

Graphical background daemons (e.g. EasyEffects, DeltaTune, Solaar) must not start on headless sessions or linger across compositor exits. Scope them to the Wayland session:

```nix
systemd.user.services.<name> = {
  Unit = {
    After = lib.mkForce [
      "hyprland-session.target"
      "pipewire.service"
      "wireplumber.service"
    ];
    PartOf = lib.mkForce [ "hyprland-session.target" ];
    ConditionEnvironment = "WAYLAND_DISPLAY";
  };
  Service.Slice = "session.slice";
  Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
};
```

## 4. Package Wrappers (`pkgs/`)

Prefer `symlinkJoin` + `makeWrapper` (`wrapProgram`) over full `overrideAttrs` rebuilds when setting environment flags:

```nix
pkgs.symlinkJoin {
  name = "app-wrapped";
  paths = [ pkgs.app ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/app --set ENV_VAR value
  '';
}
```

## 5. Verification Runbook

1. Format and verify formatting:
   ```sh
   nix fmt && nix fmt -- --ci
   ```
2. Fast targeted evaluation during iteration:
   ```sh
   nix eval .#nixosConfigurations.pangu.config.system.build.toplevel.drvPath
   nix eval .#nixosConfigurations.gonggong.config.system.build.toplevel.drvPath
   ```
3. Run lightweight contract/regression checks (`desktop-contract`, `hyprland-lua`, `hyprland-contract`, `home-manager-backups`, `flatpak-font-cache`):
   ```sh
   nix build --no-link \
     .#checks.x86_64-linux.desktop-contract \
     .#checks.x86_64-linux.hyprland-lua \
     .#checks.x86_64-linux.hyprland-contract \
     .#checks.x86_64-linux.home-manager-backups \
     .#checks.x86_64-linux.flatpak-font-cache
   ```
4. Full gate before finishing:
   ```sh
   nix flake check -L
   nix build --no-link .#checks.x86_64-linux.pangu-system
   ```
