# nixos-config

Flake-based NixOS + Home Manager configuration for two machines:

- **pangu** — AMD/NVIDIA desktop, runs **Pangu**, a Quickshell desktop shell.
- **gonggong** — headless server.

Everything host-specific is parameterized through the `mySystem.*` options
layer, so a new host is a `hosts/<name>/` directory plus one entry in the
`hosts` attrset in `nix/hosts.nix`.

Design rules, ownership and the file layout are in
[docs/architecture.md](docs/architecture.md). The kernel AutoFDO loop is in
[docs/autofdo.md](docs/autofdo.md).

## Day-to-day

| Alias | Does |
| ----- | ---- |
| `snis` / `snub` | `nh os switch` / `boot` |
| `snus` | switch + update inputs |
| `snuf` | clean old generations |
| `nfu` | update flake inputs |

`snuf` uses `mySystem.system.keepGenerations`. Hosts that import
`performance/kernel.nix` (pangu) also get a `fallback` specialisation (stock
kernel, no sched_ext) in the boot menu.

## Verification

There are two different things commonly called "check":

- `nix flake check --no-build` only **evaluates**. GitHub CI runs this plus the
  lightweight checks (Hyprland Lua, the `generated.lua` contract, shell-settings).
- `nix build .#checks.x86_64-linux.<host>-system` is the **real build**
  (qmllint, the shell test suite, and the system closure). Garnix builds every
  `checks.x86_64-linux.*` on push.

Building is not switching — activation (`snis`) is a deliberate manual step.

## Layout

```
flake.nix                  Inputs and output wiring only
checks.nix                 flake checks (host toplevels + the extra checks)
nix/hosts.nix              mkHost + the host set
hosts/<name>/
  configuration.nix        mySystem values for the machine
  hardware-configuration.nix
  home.nix                 Home Manager bundle + host-specific modules
  packages.nix             flat home.packages list
modules/nixos/
  options/                 the shared, typed mySystem.* API
  bundle.nix               base modules imported by every host
  desktop/bundle.nix       graphical stack, imported only by desktops
  core/ desktop/ hardware/ performance/ programs/ services/
modules/home-manager/      user session; reads system values via osConfig
  bundle.nix               base HM bundle (CLI, stateVersion)
  desktop/bundle.nix       desktop session bundle
  lib/                     mkAutostart + shell-settings merge
  cli/ desktop/ programs/ services/
pkgs/                      packages built here (overlay), not flake inputs
  pangu/                   the shell wrapper + CLI
  autofdo/ ttf-phosphor-icons/
share/                     source trees deployed verbatim, no nix inside
  shell/                   the Quickshell shell (QML + scripts); its own
                           JS/Python tests live in share/shell/tests
  hypr/                    Hyprland Lua config
tests/                     flake-level checks (hypr Lua, shell settings)
docs/                      architecture and task guides
```

## Pangu, the desktop shell

Pangu (`share/shell`, packaged as `pkgs.pangu`) is a Quickshell shell forked
from [Axenide/Ambxst](https://github.com/Axenide/Ambxst) (AGPL-3.0, see
`share/shell/LICENSE`) and since diverged. It runs as an ordinary user service;
`pkgs.pangu` execs Quickshell on `share/shell` with a pinned runtime PATH, and
the same binary is the CLI (`pangu run launcher`, `pangu lock`, …) keybinds and
idle listeners invoke.

The shell's runtime settings live in `~/.config/pangu/config/*.json`, which the
shell rewrites, so they cannot be store symlinks. The schema and defaults are
the adapters in `share/shell/config/Config.qml`; a missing file or key resolves
to them. `mySystem.desktop.shell.settings` only re-asserts nix-owned keys on
each start — see [docs/architecture.md](docs/architecture.md#settings-ownership).

## Hyprland

Keybinds, autostarts, layouts and window rules are `share/hypr/*.lua`; monitors,
workspace rules and environment come from the Home Manager-generated
`~/.config/hypr/hyprland.lua`. Appearance (gaps, borders, blur, rounding,
shadows) is owned by Pangu, which writes `~/.local/share/pangu/hyprland.lua`;
`share/hypr/shell.lua` sources it. `generated.lua` carries the remaining nix
state to the Lua config.
