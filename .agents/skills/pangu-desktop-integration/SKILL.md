---
name: pangu-desktop-integration
description: >-
  Guides changes across Pangu-Shell (/home/jesperls/Source/Pangu-Shell) and
  nixos-config for QML widgets/services, Hyprland Lua configuration, monitors,
  matugen theme/palette exports (GTK, Qt, Kitty, Firefox, Vesktop, Spicetify),
  and live desktop debugging. Use whenever touching desktop, Hyprland, theme,
  or Pangu shell behavior.
---

# Pangu & Desktop Integration Workflow

Read [docs/desktop.md](../../../docs/desktop.md) before modifying desktop integration or ownership boundaries.

## 1. Ownership Split (`nixos-config` vs `Pangu-Shell`)

| Concern | Owner | Path |
| --- | --- | --- |
| Monitors, scaling, HDR/VRR, workspace distribution | `nixos-config` | `hosts/pangu/monitors.nix`, `modules/home-manager/desktop/hyprland/settings.nix` |
| Host app shortcuts (`SUPER+R/D/M`), mouse binds, default apps | `nixos-config` | `hosts/pangu/home.nix`, `modules/nixos/options/apps.nix` |
| Static Nix theme presets & GTK/Qt/cursor packages | `nixos-config` | `modules/nixos/options/theme-presets.nix`, `modules/home-manager/desktop/theme.nix` |
| Shell QML UI, services, macros, audio/wallpaper helpers, shaders | `Pangu-Shell` | `/home/jesperls/Source/Pangu-Shell/shell/`, `scripts/` |
| Hyprland Lua hooks, layouts, binds, window rules | `Pangu-Shell` | `/home/jesperls/Source/Pangu-Shell/hyprland/pangu/`, `hyprland/defaults.nix` |
| Reusable `programs.pangu` NixOS & HM modules + runtime wrapper | `Pangu-Shell` | `/home/jesperls/Source/Pangu-Shell/nix/{modules,package}/` |

## 2. End-to-End Cross-Repo Workflow

`flake.nix` pins `github:jesperls/Pangu-Shell` so GitHub CI and Garnix evaluate without local paths. Editing `/home/jesperls/Source/Pangu-Shell` alone has zero effect on the installed shell until committed, pushed, and locked here.

1. **Develop & test in `/home/jesperls/Source/Pangu-Shell`**:
   ```sh
   cd /home/jesperls/Source/Pangu-Shell
   # Fast inner loop (optional):
   nix develop -c bash scripts/rebake-shaders.sh
   nix develop -c node shell/tests/test_services.js
   nix develop -c env PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s shell/tests -v
   # Full Pangu gate (required before commit):
   nix fmt && nix fmt -- --ci
   nix flake check -L
   ```
2. **Test local Pangu against `nixos-config` before pushing (optional)**:
   ```sh
   cd /home/jesperls/nixos-config
   nix build --no-link --override-input pangu-shell /home/jesperls/Source/Pangu-Shell .#pangu
   ```
   Never commit a local `path:` or `git+file://` URL into `flake.nix`.
3. **Commit & push `Pangu-Shell`, then lock & verify in `nixos-config`**:
   ```sh
   git -C /home/jesperls/Source/Pangu-Shell push
   cd /home/jesperls/nixos-config
   nix flake update pangu-shell
   nix fmt && nix fmt -- --ci
   nix flake check -L
   nix build --no-link .#checks.x86_64-linux.pangu-system
   ```

## 3. Hyprland Lua & State Boundaries

- Home Manager writes two immutable entrypoints:
  - `~/.config/hypr/hyprland.lua`: monitors, workspace rules, cursor env, then `require("pangu.init")`.
  - `~/.config/hypr/pangu/generated.lua`: serialized Nix settings consumed by Pangu's Lua modules (validated by `checks.x86_64-linux.hyprland-contract`).
- Pangu writes mutable runtime Lua under `~/.local/share/pangu/{hyprland,macros,gamemode,hypr-layout-state}.lua`.
- **Trap**: Both `settings.lua` and Pangu's `hyprland.lua` write to Hyprland's `general` table on disjoint keys (e.g. layout/tearing vs gaps/borders). Keep those key sets disjoint.
- Fractional monitor scaling must produce integer `gaps_out` values in special workspace rules (enforced by `tests/desktop-contract.nix`).

## 4. Theme & Palette Export Pipeline

When `mySystem.desktop.shell.enable = true`:
- Pangu generates palettes via `matugen` and writes live exports to:
  - `~/.cache/pangu/{gtk.css,kitty.conf,firefox.css}`
  - `~/.config/qt{5,6}ct/colors/pangu.colors`
  - `~/.config/vesktop/themes/pangu.css`
  - `~/.config/spicetify/Themes/Pangu/{color.ini,user.css}`
- **Trap**: Do not emit static Home Manager color definitions that shadow Pangu's runtime includes when `osConfig.mySystem.desktop.shell.enable` is true (see `shellManaged` in [kitty.nix](../../../modules/home-manager/desktop/kitty.nix) and `shellPalette` in [theme.nix](../../../modules/home-manager/desktop/theme.nix)).

## 5. Mutable Shell Config & Live Debugging

- `~/.config/pangu/config/*.json` are mutable user files, not store symlinks.
- `mySystem.desktop.shell.settings` merges partial overrides before `pangu.service` starts and exports overridden dot-paths in `PANGU_NIX_OVERRIDES`.
- Useful diagnostic commands (read-only / non-switching):
  ```sh
  systemctl --user status pangu.service
  journalctl --user -u pangu.service -b -n 100 --no-pager
  hyprctl configerrors
  pangu help
  ```
- Remind the user to run `snis` to activate system/shell builds; never run `snis` yourself.
