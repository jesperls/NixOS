# nixos-config

Flake-based NixOS + Home Manager configuration. Single host for now (`pangu`),
but everything host-specific is parameterized through the `mySystem` options
layer, so a new host is a `hosts/<name>/` directory plus one entry in the
`hosts` list in `flake.nix`.

## Layout

```
flake.nix                  Inputs + mkHost. `checks` is derived from
                           nixosConfigurations, so every host is CI-built.
Ambxst/                    Local fork of the Ambxst desktop shell (gitignored).
                           Owns Hyprland appearance and app colors. Consumed as
                           github:jesperls/Ambxst — push before a flake update,
                           or iterate locally with `snil ambxst`.
hosts/pangu/
  configuration.nix        Entry point: mySystem settings only.
  modules.nix              Host-specific NixOS modules (hardware, gaming...).
  home.nix                 HM bundle + host-specific HM modules.
  theme.nix                Theme preset + structural overrides.
  monitors.nix             Monitor list (resolution, refresh, vrr, ...).
  packages.nix             Flat home.packages list. ⚠ Machine-edited by
                           quickshell-package-manager — keep it a flat list.
modules/nixos/
  options/                 The whole `mySystem.*` API:
    system.nix             user, system, paths, monitors
    theme.nix              palette/preset, gaps, blur, fonts, gtk/qt
    theme-presets.nix      named palettes (obsidian-mocha, catppuccin, ...)
    desktop.nix            lockscreen, idle, layouts, special workspaces, gaming
    apps.nix               defaultApps — single source of truth for
                           terminal/browser/editor/viewers
  bundle.nix               Common imports shared by all desktop hosts.
  home-manager.nix         Generic HM wiring (rotating activation backups).
  core/ services/ ...      Implementation modules reading mySystem.*.
modules/home-manager/
  bundle.nix               Common HM imports shared by all desktop hosts.
  lib/autostart.nix        mkAutostart — systemd user unit bound to the
                           Hyprland session.
  ...                      HM modules; read system config via osConfig.
```

## The mySystem theme pipeline

`mySystem.theme` (palette picked via `theme.preset`, override any color
individually) flows into:

- Hyprland (borders, gaps, blur, shadows, animations) via `generated.lua` —
  unless Ambxst is enabled, in which case Ambxst owns those settings
- kitty, fzf, starship colors
- GTK (adw-gtk3 + accent CSS), Qt (qt5ct/qt6ct palette + Fusion; the custom
  palette is only wired up when Ambxst is there to generate it)
- quickshell-package-manager via its `baseColors` option (derived into a
  full M3 palette at build time)

Keybinds, autostarts, and layouts always come from the nix-managed Lua
config (`modules/home-manager/desktop/hyprland/lua/`); Ambxst's own
management of them is switched off by an `ExecStartPre` on its service.

## Subproject development

The quickshell apps (Ambxst, qs-vpets, nix-quickshell-package-manager) are
checked out inside this directory (all gitignored) and consumed as flake
inputs from GitHub. For local iteration without pushing, rebuild with inputs
overridden to the local checkouts:

```
snil ambxst                     # any combination of inputs works
```

Thanks to the `follows` graph this only rebuilds the app itself, not
quickshell or a second nixpkgs.

## Day-to-day

| Alias | Does |
| ----- | ---- |
| `snis` / `snub` | `nh os switch` / `boot` |
| `snus` | switch + update inputs |
| `snil <input>...` | switch with local subproject checkouts |
| `snuf` | clean old generations |

The lockscreen is scaffolded but disabled by default
(`mySystem.desktop.lockscreen.enable`) — flip it on when the machine is
somewhere untrusted. `mySystem.system.autoLogin` and
`.passwordlessSudo` are the other two knobs that trade security for
convenience; both default to off and are opted into by `pangu`.

CI: GitHub Actions evaluates the flake (no builds); garnix builds
`checks.x86_64-linux.*` and serves results from cache.garnix.io (already in
the substituters), so `snus` after a push is mostly downloads.
