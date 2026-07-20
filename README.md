# nixos-config

Flake-based NixOS + Home Manager configuration. Single host for now (`pangu`),
but everything host-specific is parameterized through the `mySystem` options
layer so additional hosts only need their own `hosts/<name>/` directory.

## Layout

```
flake.nix                  Inputs + nixosConfigurations. Quickshell subprojects
                           are consumed from github:jesperls/* (Ambxst from the
                           local checkout via git+file), with `follows` pinning
                           everything to one nixpkgs + one quickshell.
Ambxst/                    Local fork of the Ambxst desktop shell. Owns Hyprland
                           appearance and app colors; commit here before a flake
                           update so the git+file input picks it up.
hosts/pangu/
  configuration.nix        Entry point: mySystem settings, HM wiring.
  modules.nix              Host-specific module imports (hardware, gaming...).
  theme.nix                Theme preset + structural overrides.
  monitors.nix             Monitor list (resolution, refresh, vrr, ...).
  packages.nix             Flat home.packages list. ⚠ Machine-edited by
                           quickshell-package-manager — keep it a flat list.
modules/nixos/
  options/                 The whole `mySystem.*` API:
    system.nix             user, system, paths, monitors
    theme.nix              palette/preset, gaps, blur, fonts, gtk/qt
    theme-presets.nix      named palettes (obsidian-mocha, catppuccin, ...)
    desktop.nix            lockscreen, gaming (tearing)
    apps.nix               defaultApps — single source of truth for
                           terminal/browser/editor/viewers
  bundle.nix               Common imports shared by all desktop hosts.
  core/ services/ ...      Implementation modules reading mySystem.*.
modules/home-manager/      HM modules; read system config via osConfig.
```

## The mySystem theme pipeline

`mySystem.theme` (palette picked via `theme.preset`, override any color
individually) flows into:

- Hyprland (borders, gaps, blur, shadows, animations) via `generated.lua` —
  unless Ambxst is enabled, in which case Ambxst owns those settings
- kitty, fzf, starship colors
- GTK (adw-gtk3 + accent CSS), Qt (qt5ct/qt6ct palette + Fusion)
- quickshell-package-manager via its `baseColors` option (derived into a
  full M3 palette at build time)

Keybinds, autostarts, and layouts always come from the nix-managed Lua
config (`modules/home-manager/desktop/hyprland/lua/`); Ambxst's own
management of them is switched off by an `ExecStartPre` on its service.

## Subproject development

The quickshell apps (Ambxst, qs-vpets, nix-quickshell-package-manager) are
checked out inside this directory and consumed as flake inputs — Ambxst
directly from its checkout, the others from GitHub (checkouts gitignored).
For local iteration without pushing, rebuild with inputs overridden to the
local checkouts:

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
somewhere untrusted.

CI: GitHub Actions evaluates the flake (no builds); garnix builds
`checks.x86_64-linux.*` and serves results from cache.garnix.io (already in
the substituters), so `snus` after a push is mostly downloads.
