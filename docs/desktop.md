# Desktop

## Where to change things

| Change | Source |
| --- | --- |
| Monitors, scale and placement | [hosts/pangu/monitors.nix](../hosts/pangu/monitors.nix) |
| Input, layout defaults, tearing and default applications | `mySystem` options in the host configuration |
| Keybindings, window rules and layout behaviour | [share/hypr](../share/hypr) |
| Shell controls and visual components | [share/shell/modules](../share/shell/modules) |
| Shell defaults and JSON schema | [Config.qml](../share/shell/config/Config.qml) |
| Shell dependencies and build checks | [pkgs/pangu/default.nix](../pkgs/pangu/default.nix) |

Home Manager writes `~/.config/hypr/hyprland.lua` and
`~/.config/hypr/pangu/generated.lua`. The first contains monitors, workspace
rules and cursor environment, then loads `pangu.init`. The second exports Nix
values to the Lua files in `share/hypr`. Edit their sources in the repo rather
than either generated file.

Pangu controls gaps, borders, rounding, blur, shadows and wallpaper colours.
It writes `~/.local/share/pangu/{hyprland,macros,gamemode}.lua`, which the Lua
configuration loads. `settings.lua` and Pangu both configure Hyprland's
`general` section, but write different keys. Keep those keys separate when
adding a setting.

Home Manager selects fonts, cursor and GTK/Qt theme names. Pangu generates
the desktop palette with matugen. The managed GTK stylesheets import
`~/.cache/pangu/gtk.css`; palette updates write that cache file.

## Persistent settings

The shell reads and rewrites `~/.config/pangu/config/*.json`. These are mutable
files, not Nix store symlinks. Missing keys use the defaults in `Config.qml`.
The paths shown here use the usual XDG defaults; the shell respects overrides.

An optional `mySystem.desktop.shell.settings` value is merged into those files
before every service start. For example, inside a NixOS configuration:

```nix
mySystem.desktop.shell.settings = {
  system.ocr.spa = false;
};
```

Only the specified keys are overwritten; sibling settings survive. Changes to
those keys in the GUI last until the next shell start. Removing a Nix override
leaves its last saved value in the JSON. No current host uses this override
channel.

`~/.local/share/pangu` also holds persistent shell state, while
`~/.cache/pangu` holds generated palettes and caches. Idle and audio-visualizer
configs live under `$XDG_RUNTIME_DIR/pangu`. The separate
`$XDG_RUNTIME_DIR/pangu-session-started` marker prevents service restarts from
being treated as a fresh login by the lockscreen.

## Running and debugging

Pangu runs as `pangu.service` under the user manager, tied to
`hyprland-session.target`. The `pangu` wrapper supplies Quickshell, QML imports
and external tools; running the QML directly skips that setup.

```sh
systemctl --user status pangu.service
journalctl --user -u pangu.service -b -n 100 --no-pager
hyprctl configerrors
pangu help
```

Use `pangu run launcher`, `pangu run dashboard` or `pangu lock` to exercise
controls. `pangu reload` restarts the service using its installed package.
Repository edits become part of that package only after rebuilding and
activating the configuration.

For a package build without activation:

```sh
nix build .#pangu
```

The package compiles `.frag` and `.vert` shader sources into `.qsb` files.
Those outputs are not committed. To prepare shaders for running QML from a
checkout, use the flake's Qt tools:

```sh
nix shell --inputs-from . nixpkgs#qt6.qtshadertools \
  -c bash pkgs/pangu/rebake-shaders.sh
```

Most external commands are pinned in the wrapper's `runtimeInputs`. Add new
dependencies there. `nvidia-smi` comes from the system driver; optional
EasyEffects and pywal integrations use the session PATH.

## Changing shell code

[shell.qml](../share/shell/shell.qml) starts the services and creates surfaces
per screen. `UnifiedShellPanel` assembles the bar, notch, dock and frame.
Backends live in `modules/services`; UI components consume them. `Config`
contains settings and must not import services. Hyprland access goes through
`Compositor.qml`, and paths through `config/Paths.qml`.

Use `ConfigFile` for adapter-shaped JSON, `JsonStore` for dynamic-key JSON and
`GeneratedFile` for generated text. The latter reports completion after the
latest output is written, so consumers can reload safely.

Settings panels use `Config.snapshot`/`restore` and
`Config.beginEdit`/`save`/`endEdit` to support Apply and Discard. Drafting pauses
autosave for whole files: keep one drafting owner per file. The `system`
section is excluded from shell drafts so OCR changes save immediately.

When adding a searchable setting, update both its adapter and
`SettingsIndex.qml`. Shell tests live in [share/shell/tests](../share/shell/tests);
configuration-level Lua and Nix tests live in [tests](../tests).
