# nixos-config

Flake-based NixOS + Home Manager configuration. Two hosts: `pangu` (desktop)
and `gonggong` (headless server), but everything host-specific is
parameterized through the `mySystem` options layer, so a new host is a
`hosts/<name>/` directory plus one entry in the `hosts` attrset in `flake.nix`
(which can override `system` and inject extra modules per host).

## Layout

```
flake.nix                  Inputs + mkHost. `checks` is derived from
                           nixosConfigurations, so every host is CI-built.
hosts/pangu/
  configuration.nix        Entry point: mySystem settings only, including the
                           enable flags for hardware/gaming/service modules.
  home.nix                 HM bundle + host-specific HM modules.
  theme.nix                Theme preset + structural overrides.
  monitors.nix             Monitor list (resolution, refresh, vrr, ...).
  packages.nix             Flat home.packages list.
modules/nixos/
  options/                 The shared `mySystem.*` API:
    system.nix             user, system, paths, network.hosts, monitors
    theme.nix              palette/preset, fonts, gtk/qt, animations, opacity
    theme-presets.nix      named palettes (obsidian-mocha, catppuccin, ...)
    desktop.nix            shell, layouts, special workspaces, gaming,
                           input, render (direct scanout), autoFakeFullscreen
    apps.nix               defaultApps — single source of truth for
                           terminal/browser/editor/viewers
    performance.nix        sched_ext scheduler, ananicy, irqbalance, zram,
                           earlyoom
    assertions.nix         cross-option sanity checks
                           (module-specific options like hardware.nvidia.enable
                           or services.sunshine.enable are declared next to
                           their implementation module instead)
  bundle.nix               Base bundle shared by every host: core, performance
                            and feature modules, which are off until their
                            mySystem enable flag is set.
  desktop/bundle.nix        The graphical stack (compositor, portals, audio,
                            Bluetooth, fonts) — imported only by hosts that
                            want a desktop.
  home-manager.nix         Generic HM wiring (rotating activation backups).
  core/ services/ ...      Implementation modules reading mySystem.*.
modules/home-manager/
  bundle.nix               Base HM bundle: CLI tooling + stateVersion.
  desktop/bundle.nix        Desktop session (theme, xdg, mimeapps, Hyprland,
                            shell, autostarts, mpv) — imported per host.
                            Standalone apps (firefox, nixcord, obs, ...) are
                            not in any bundle; hosts import them directly.
  lib/autostart.nix        mkAutostart — systemd user unit bound to the
                           Hyprland session.
  desktop/shell.nix        The shell's user service + config bootstrap.
  desktop/hyprland/        Hyprland: nix-generated settings + the Lua drop-in.
  ...                      HM modules; read system config via osConfig.
pkgs/                      Packages this config builds itself, exposed as
                           `overlays.default`. Nothing here comes from a
                           flake input.
  pangu/                   Launcher + CLI wrapping share/shell.
  ttf-phosphor-icons/      The shell's icon font.
share/                     Source trees deployed verbatim — no nix in here.
  shell/                   The Quickshell desktop shell (QML). See below.
  hypr/                    Hyprland's Lua config, deployed to
                           ~/.config/hypr/pangu/.
                           shell.lua sources what Pangu generates.
```

## Adding a host

A new `hosts/<name>/` needs `configuration.nix` and
`hardware-configuration.nix`. The entrypoint composes the host from bundles:
`modules/nixos/bundle.nix` is always the base, and a desktop host adds
`modules/nixos/desktop/bundle.nix`; on the HM side the same split applies,
with standalone apps imported à la carte in `home.nix`.

Nothing in the shared layer has to be configured — hardware-shaped modules
(`mySystem.hardware.*`, `programs.gaming`, `services.sunshine`, ...) default
to off and are switched on per host, and `performance.cpuVendor` is read from
`hardware-configuration.nix`. Headless hosts import no desktop bundle, so no
`monitors.nix` is needed either (the monitor assertion only fires when
Hyprland is actually enabled).

Overriding the baseline per host:

| Knob | How |
| ---- | --- |
| `performance.zram.*`, `.earlyoom.*`, `.noatime`, `.ananicy`, `.irqbalance` | `mySystem` options. |
| `boot.kernel.sysctl.*` | Priority 500 — plain assignment wins, no `mkForce`. |
| `boot.kernelPackages`, `boot.initrd.systemd.enable`, `nix.settings` sizing | `mkDefault`; assign to replace. |

`systemd.oomd.enable` follows `performance.earlyoom.enable` inversely.

## share/ — the static trees

`share/` holds the two trees that are *content* rather than configuration:
they are copied into the store as-is and read at runtime. Nothing under
`share/` contains nix; everything it needs from the configuration arrives
through a generated file or the environment.

```
share/shell/
  shell.qml              Entry point: ShellRoot + Variants per screen.
  config/                Config + Paths singletons, PAM config.
  modules/               The QML itself — bar, notch, dock, dashboard,
                         lockscreen, services, theme generators, ...
  assets/                Icons, color presets, layout presets, sounds.
  scripts/               Python/Bash backends the QML shells out to.
share/hypr/
  init.lua               Requires every other module in order.
  generated.lua          ⚠ Written by nix at build time — not in the repo.
  binds.lua settings.lua layouts.lua ...
```

Both trees resolve their own paths at runtime instead of having them baked in:
`share/shell/config/Paths.qml` derives every path from `Quickshell.shellDir`
and the XDG variables, and `share/hypr/generated.lua` is the single door
through which `mySystem.*` reaches the Lua.

## Pangu, the desktop shell

`mySystem.desktop.shell` runs **Pangu** — a Quickshell shell forked from
[Axenide/Ambxst](https://github.com/Axenide/Ambxst) (AGPL-3.0, see
`share/shell/LICENSE`) and since diverged far enough to be its own thing. It is
an ordinary user service:

- `pkgs.pangu` execs Quickshell on `share/shell` with a private runtime
  environment on its PATH. Only `bin/pangu` reaches a profile — the tools the
  shell shells out to never land in the system closure's `bin`.
- It talks to Hyprland through Quickshell's own `Quickshell.Hyprland` module —
  `modules/services/Compositor.qml` is the single place that does, wrapping the
  live window/workspace/monitor models, the Lua dispatchers and one-shot
  `hyprctl` requests over `Hyprland.requestSocketPath`. Idle timeouts and the
  inhibitors other apps set run through `Quickshell.Wayland`'s `IdleMonitor`.
  There is no compositor daemon of our own any more.
- The same binary is the CLI (`pangu run launcher`, `pangu brightness +5`,
  `pangu lock`) that keybinds and the idle listeners invoke.
- Its settings live in `~/.config/pangu/config/*.json`, which the shell
  rewrites at runtime, so they cannot be store symlinks. The schema and its
  defaults are the `JsonAdapter` blocks in `share/shell/config/Config.qml` —
  a missing file or key resolves to them, so nothing needs seeding. The
  service only re-asserts the nix-owned keys on every start;
  `mySystem.desktop.shell.settings` is that set.

### Who owns what

| Concern | Owner |
| ------- | ----- |
| Window decoration — borders, gaps, blur, rounding, shadows | Pangu, live from its settings UI. It writes `~/.local/share/pangu/hyprland.lua`, which `share/hypr/shell.lua` sources. |
| Keybinds, autostarts, layouts, window rules, monitors | `share/hypr/*.lua` + `generated.lua`. Pangu has no code for these at all — not a flag to switch off. |
| Per-workspace game mode | Pangu owns the set of workspaces; it emits the rules into the same generated Lua and hands the set back for `layouts.lua` to square the bar's split strip. |
| Animations, per-app opacity | nix, through `generated.lua`. |
| Palette, fonts, GTK/Qt/cursor themes | `mySystem.theme`, which every app inherits. Pangu derives its own palette from the wallpaper on top. |

`mySystem.theme` deliberately has no border/gap/blur options: they would be a
second, silently-losing source of truth for settings you actually change
through the shell.

### How the pieces talk

Every channel below has exactly one job. If you find yourself adding a second
way to do one of these, delete the first one instead.

| From → to | Channel |
| --------- | ------- |
| Hyprland → shell (commands) | `pangu run <target>` → `qs ipc call` → the `pangu` `IpcHandler` in `GlobalShortcuts.qml`. Every keybind that touches the shell goes through this. |
| Hyprland → shell (state, events) | `Quickshell.Hyprland`, wrapped by `modules/services/Compositor.qml`. Custom `hl.dsp.event` payloads (`centergap`) arrive on the same `rawEvent`. |
| shell → Hyprland (commands) | `Compositor.dispatch()`, which translates to `hl.dsp.*` — Hyprland's Lua config accepts nothing else over IPC. |
| shell → Hyprland (config) | `CompositorTheme.qml` writes `~/.local/share/pangu/hyprland.lua`; `share/hypr/shell.lua` sources it and passes its return value back up. |
| nix → Hyprland | `generated.lua`. |
| nix → shell | `pangu.service`'s `ExecStartPre` jq-patches the nix-owned keys into `~/.config/pangu/config/*.json`. |
| wallpaper → everything | matugen writes `~/.cache/pangu/colors.json`; the `Colors` FileView watches it. |

## The mySystem theme pipeline

`mySystem.theme` (palette picked via `theme.preset`, override any color
individually) flows into:

- Hyprland (borders, gaps, blur, shadows, animations) via `generated.lua` —
  unless the shell is enabled, in which case it owns those settings
- kitty, fzf, starship colors
- GTK (adw-gtk3 + accent CSS), Qt (qt5ct/qt6ct palette + Fusion; the custom
  palette is only wired up when the shell is there to generate it)
## Day-to-day

| Alias | Does |
| ----- | ---- |
| `snis` / `snub` | `nh os switch` / `boot` |
| `snus` | switch + update inputs |
| `snuf` | clean old generations |
| `nfu` | update flake inputs only |

Every build also produces a `fallback` specialisation (stock nixpkgs kernel,
no sched_ext) selectable from the boot menu if a CachyOS kernel or scheduler
update misbehaves.

Manual kernel AutoFDO (profile collection → merge → rebuild) is documented in
[docs/autofdo.md](docs/autofdo.md).

Locking is `loginctl lock-session` (`SUPER L` / the power menu); idle
timeouts and lock-on-boot/sleep live in the shell's settings UI under
System → Idle. `mySystem.system.autoLogin` and `.passwordlessSudo` trade
security for convenience; both default to off and are opted into by `pangu`.

CI: GitHub Actions evaluates the flake (no builds); garnix builds
`checks.x86_64-linux.*` and serves results from cache.garnix.io (already in
the substituters), so `snus` after a push is mostly downloads.
