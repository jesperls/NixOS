# Desktop

## Where to change things

| Change | Source |
| --- | --- |
| Monitors, scale and placement | [hosts/pangu/monitors.nix](../hosts/pangu/monitors.nix) |
| Input, layout defaults, tearing and default applications | `mySystem` options in the host configuration |
| Keybindings, window rules and layout behaviour | Pangu `hyprland/pangu`, configured through the local Hyprland adapter |
| Shell controls and visual components | Pangu `shell/modules` |
| Shell defaults and JSON schema | Pangu `shell/config/Config.qml` |
| Shell dependencies and build checks | Pangu `nix/package/default.nix` |

The standalone [Pangu repository](https://github.com/jesperls/Pangu-Shell) owns
the shell, its Hyprland integration and reusable Nix modules. This configuration enables its
optional desktop preset and supplies the existing monitors, applications and
desktop preferences. The FFmpeg 8 recorder override remains in this repository
for the installed NVIDIA driver.

Home Manager writes `~/.config/hypr/hyprland.lua` and
`~/.config/hypr/pangu/generated.lua`. The first contains monitors, workspace
rules and cursor environment, then loads `pangu.init`. The second exports Nix
values to Pangu's Lua files. Edit their sources in the Pangu checkout rather
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
Commit and push shell edits to the Pangu repository, run
`nix flake update pangu-shell` here, then rebuild and activate the configuration.
The GitHub input is pinned to a commit; editing a local checkout alone does not
change the installed shell.
For development without activation, use `nix run .#dev` in the Pangu checkout
after stopping the installed service.

Sunshine's user service forces `capture=wlr` through a command-line override
to use Hyprland's direct capture protocol without portal selection dialogs.
It runs without `CAP_SYS_ADMIN`; other settings and applications remain
editable in Sunshine's web UI and persist under `~/.config/sunshine`.

For a package build without activation:

```sh
nix build .#pangu
```

The package compiles `.frag` and `.vert` shader sources into `.qsb` files.
Those outputs are not committed. To prepare shaders for running QML from a
checkout, use the flake's Qt tools:

```sh
cd /home/jesperls/Source/Pangu-Shell
nix develop -c bash scripts/rebake-shaders.sh
```

Most external commands are pinned in the wrapper's `runtimeInputs`. Add new
dependencies there. `nvidia-smi` comes from the system driver; optional
EasyEffects and pywal integrations use the session PATH.

## Changing shell code

Pangu's `shell/shell.qml` starts the services and creates surfaces
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
`SettingsIndex.qml`. Shell and reusable-module tests live in the Pangu checkout;
host configuration tests live in [tests](../tests).
