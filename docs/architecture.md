# Architecture

This is the design contract for the repo. It says which layer owns what and
where a change belongs. When a change does not fit, change this document first
— do not add a second mechanism beside the existing one.

## Principles

1. **One owner per setting.** Every value has exactly one writer. If two things
   can write it, one of them is wrong.
2. **Layers point one way.** `flake → host → mySystem option → module →
   runtime`. Config flows down; modules never reach up into hosts.
3. **Capabilities, not aliases.** A `mySystem.*.enable` flag earns its name only
   when another module reads it. A flag that just re-spells an upstream option
   is indirection and should be deleted.
4. **Hosts are data, modules are policy.** A host sets values. It does not
   contain behavior, and it does not work around a module's defaults.
5. **Fail visibly, verify by building.** `nix flake check` only evaluates;
   `nix build .#checks…` and `pkgs.pangu`'s own test phase are the gate.
   A "targeted" or "activated" claim in prose is not evidence.

## Layers

```
flake.nix -> nix/hosts.nix
  mkHost = [ hosts/<h>/configuration.nix, home-manager.nixosModules, overlays ] ++ modules
        │
        ▼
hosts/<h>/configuration.nix     mySystem values + explicit module imports
        │
        ├── modules/nixos/bundle.nix          base, every host
        │     options/  core/{boot,network,nix,locale}
        │     performance/{optimizations,scheduling}
        │     home-manager.nix  users.nix
        ├── modules/nixos/desktop/bundle.nix  graphical, desktops only
        │     desktop/{common,hyprland,shell}.nix  services/{audio,bluetooth}
        │     programs/fonts.nix
        └── feature modules the host imports explicitly
              hardware/*  programs/*  services/*
              performance/{kernel,autofdo}

hosts/<h>/home.nix
        ├── modules/home-manager/bundle.nix          base HM
        └── modules/home-manager/desktop/bundle.nix  desktop HM
```

Feature modules are **not** in the base bundle. A host imports the ones it
wants, and a feature module is unconditional once imported — there is no
`enable` gate for code only the module itself reads. A `mySystem.*.enable` flag
survives only when a *different* module reads it as a capability (for example
`hardware.nvidia.enable`, read by Sunshine and OBS to pick CUDA).

`specialArgs = { inherit inputs; }` is the only channel from `flake.nix` into
modules. Home Manager reads system-level values exclusively through
`osConfig.mySystem.*`.

## The `mySystem` API

Subtree ownership:

- `mySystem.{user,system,network,paths,monitors,home}` — identity and machine
  facts (`options/system.nix`).
- `mySystem.theme` — palette, fonts, GTK/Qt/cursor **names**
  (`options/theme.nix`; presets in `theme-presets.nix`).
- `mySystem.desktop` — shell, layouts, special workspaces, input, render,
  tearing, auto-fake-fullscreen (`options/desktop.nix`).
- `mySystem.defaultApps` — the single source of truth for
  terminal/browser/editor/viewers (`options/apps.nix`).
- `mySystem.performance` — scheduler, zram, earlyoom (`options/performance.nix`);
  the kernel build options live in `performance/kernel.nix`.
- Feature-scoped options live **next to the module that implements them**
  (`hardware.nvidia`, `hardware.webcam`, `services.dlna`, …). The `options/`
  directory holds only cross-cutting API.

Rules:

- Typed option, sensible default, one-sentence description.
- Declare the option where it is implemented, unless it is cross-cutting.
- A host that wants a feature imports its module and sets its values; it does
  not set a self-only `enable` flag.
- A host that enables a cross-cutting capability sets
  `mySystem.desktop.shell.enable`, not the upstream `programs.hyprland.enable`.
- Do not add a `mySystem` option that only assigns an upstream option 1:1.

## Ownership map

| Concern | Single owner |
| ------- | ------------ |
| Identity, locale, timezone, keyboard, hostname | `mySystem.system` → `core/{locale,network}.nix` |
| Firewall / open ports | `mySystem.network` → `core/network.nix` |
| Bootloader, boot cmdline, tmpfs | `core/boot.nix` |
| Kernel package + profile | `performance/kernel.nix` (imported by desktops that want CachyOS) |
| CPU scheduler, zram, earlyoom, sysctls | `modules/nixos/performance/` |
| Filesystems, mounts, disk layout | host `hardware-configuration.nix` (+ `mySystem.performance.noatime`) |
| GPU / NVIDIA, graphics stack | `modules/nixos/hardware/nvidia.nix` |
| Theme names (GTK/Qt/cursor/fonts) | `mySystem.theme` → HM `desktop/theme.nix` |
| Palette colors used by CLI tools (starship, fzf) | `mySystem.theme.colors` → HM `cli/tools.nix` |
| Desktop palette (GTK/Qt/kitty/shell) | **Pangu**, from the wallpaper via matugen |
| Window decoration (gaps/borders/blur/shadow) | **Pangu** (`CompositorTheme.qml`) |
| Keybinds and window/layout rules | `share/hypr/*.lua` + `generated.lua` |
| Monitors, workspace rules, Hyprland env | HM `desktop/hyprland/settings.nix` → `~/.config/hypr/hyprland.lua` |
| Hyprland animations, per-app opacity | nix → `generated.lua` |
| Shell settings | `share/shell/config/Config.qml` adapters (runtime JSON) |
| Nix-owned shell keys | `mySystem.desktop.shell.settings` |
| User services / autostarts | `lib/autostart.nix` or an upstream HM `services.*` module |

## Generation channels

There are five ways configuration reaches the desktop; each has one job.

| Channel | Producer | Consumer |
| ------- | -------- | -------- |
| nix → `~/.config/hypr/pangu/generated.lua` | `desktop/hyprland/default.nix` | `share/hypr/*.lua` via `require("pangu.generated")` |
| nix → `~/.config/hypr/hyprland.lua` | HM `desktop/hyprland/settings.nix` | Hyprland (`monitor`, `workspace_rule`, `env`) |
| nix → `~/.config/pangu/config/*.json` | `desktop/shell.nix` + `lib/apply-shell-settings.nix` (`ExecStartPre`) | the shell |
| shell → `~/.local/share/pangu/hyprland.lua` | `CompositorTheme.qml` | `share/hypr/shell.lua` |
| wallpaper → `~/.cache/pangu/colors.json` | matugen (run by `WallpaperService`) | `Colors.qml` and the theme generators |

`generated.lua` and the shell JSON are merge targets, not replace targets: nix
owns only the keys it names, and the shell keeps the rest.

### Settings ownership

`mySystem.desktop.shell.settings` is a set of leaf paths that nix re-asserts on
every shell start. `lib/apply-shell-settings.nix` deep-merges them over the
existing JSON, so GUI-set sibling keys survive. `PANGU_NIX_OVERRIDES` carries
the leaf list to the settings UI, which labels those controls as temporary.
Removing an override does not restore an earlier GUI value — it leaves the last
persisted value. This contract is deliberate; do not turn the JSON into a
second system-service store (volume, credentials, pairings stay upstream).

The set of keys a settings draft or preset tracks is derived from the adapters
via `Config.adapterKeys(section)` — never hand-listed. A new adapter property is
tracked automatically; the only list to maintain is the section names in
`GlobalStates._shellSections`.

## The shell (`share/shell`)

- `shell.qml` composes per-screen surfaces; `UnifiedShellPanel.qml` owns the
  bar/notch/dock/frame and registers them with `Visibilities`.
- `config/Config.qml` declares every runtime setting as a `JsonAdapter`; a
  missing file or key falls back to the adapter default, so nothing is seeded.
- `GlobalStates` holds cross-surface UI state and draft/edit bookkeeping;
  `Visibilities` holds per-screen module visibility.
- `modules/services/` are the backends. `Compositor.qml` wraps
  `Quickshell.Hyprland`; everything talks to Hyprland through it.
- Settings changes use `Config.beginEdit(group, files)` / `Config.save` /
  `Config.endEdit(group)` so a panel's edits are drafted and can be discarded.
  Direct writers that are not user-drafts (e.g. `AutoThemeService`) call
  `Config.save` directly.
- Persistence primitives: `ConfigFile` (watched JSON adapter, autosave, reload
  watchdog; `pathOverride` for files outside the config dir) is the default for
  adapter-shaped JSON, including `wallpapers.json` and `layouts.json`.
  `ThemeFile` is the same idea for generated output files (empty writes are a
  no-op; failed writes resync and retry). Dynamic-key state (`StateService`,
  `UsageTracker`) uses `JsonStore` (directory prep, atomic writes, optional
  `normalize`). New persistent state should use one of these, not a fresh
  `FileView`.
- Dependency direction: services and `GlobalStates` observe `Config`; `Config`
  does not import them. It owns data, they own behaviour.

## Conventions

- **Naming.** Prefer one suffix convention per layer. Services are named for
  what they wrap (`Compositor`, `WeatherService`); avoid inventing new names
  for the same concept.
- **Paths.** Resolve through `config/Paths.qml`, never concatenate XDG dirs by
  hand.
- **Processes.** Direct argv; use `bash -c`/`sh -c` only when a shell operator
  is genuinely needed. Give a `Process` stdout/stderr/`onExited` handling when
  it can fail.
- **Comments.** Explain the trap, not the code. A note that a second writer
  exists is required when one is unavoidable.

## Adding things

**A host.** Create `hosts/<name>/{configuration.nix,hardware-configuration.nix,
home.nix}` and add `<name> = { };` to `hosts` in `nix/hosts.nix`. Import
`modules/nixos/bundle.nix`, plus `desktop/bundle.nix` for a graphical host.
Set `mySystem.*` values; leave defaults alone.

**A feature.** Add a module under `modules/{nixos,home-manager}/…`, declare its
options next to it, import it (bundle if universal, host if specific), and set
any cross-cutting flag a consumer needs. Delete the `enable` flag if only the
module itself reads it.

**A shell setting.** Add the property to the relevant `JsonAdapter` in
`Config.qml`, add the control's label/keywords/target to `SettingsIndex.qml`,
and (if it must be nix-owned) add it to `mySystem.desktop.shell.settings`.
The shell test fails if an index entry targets an unknown section/subsection or
if a panel subsection has no search entry.

**A test.** Lua → `tests/hyprland.lua`; flake-level Nix/Python →
`tests/`; shell behavior → `share/shell/tests/` (runs inside `pkgs.pangu`).
Exercise a failure path, not just the happy path.

## Verification model

- `nix flake check --no-build` — evaluation only (CI).
- `nix build .#checks.x86_64-linux.<host>-system` — the real build.
- garnix builds `checks.x86_64-linux.*`; GitHub CI additionally builds the
  lightweight checks (`hyprland-lua`, `hyprland-contract`, `shell-settings`).
  `cache.garnix.io` is not currently a configured substituter.
- `pkgs.pangu`'s `checkPhase` runs qmllint (syntax), the Python tests, the node
  service tests, `bash -n`, and the shader pairing check.

## Known seams (tracked, not hidden)

These are real inconsistencies that are not yet worth a risky rewrite. They are
listed so future changes do not quietly make them worse:

1. **Hyprland `general` has two writers** — `share/hypr/settings.lua`
   (layout/tearing/snap) and `CompositorTheme.qml` (gaps/border/col) both call
   `hl.config({general=…})`. Hyprland applies `hl.config` leaf-by-leaf, so this
   is safe as long as the two write disjoint leaves; the rule is one owner per
   leaf, not per section.
2. **The `pangu` `runtimeInputs` list is hand-synced** with every command the
   QML shells out to; `checks.pangu-runtime` verifies a curated set resolves
   against the built wrapper, but not every invocation is covered.
3. **Shell UI duplication.** The clipboard/notes/tmux/emoji dashboard tabs
   share a copy-pasted list/detail skeleton. Extracted to `modules/components/`:
   `SettingsToggleRow`, `SettingsNumberInputRow`, `SettingsSectionButton`,
   `OptionsListView` (options submenu), `ActionBar` (delete/rename
   cancel/confirm bar), and `ListDetailController` (the delete/rename state
   machine). The tabs' list delegates and detail panes remain tab-specific.
4. **`mySystem.desktop.shell.settings` has no production caller.** The Nix
   override channel (`apply-shell-settings.nix` + `PANGU_NIX_OVERRIDES`) is
   built, tested, and documented but no host sets a value, so it is inert at
   runtime. Set a real leaf or remove the mechanism.
5. **Settings drafts are file-granular.** `Config.beginEdit(group, files)`
   pauses autosave for a whole JSON file, so a section drafted by one panel
   blocks edits to the same file from another. `system` is therefore kept out
   of `GlobalStates._shellSections` (its OCR toggles autosave immediately);
   keep one drafting owner per config file.
6. **GTK4 `gtk.css` has two writers.** HM's `gtk` module writes
   `~/.config/gtk-4.0/gtk.css` (importing the theme CSS) and Pangu's
   `GtkGenerator` overwrites it with the wallpaper palette on every Colors
   change; a `home-manager switch` reverts it until the shell regenerates.
   Decide one owner (or have the shell emit the theme import).
7. **`noatime` is set twice on pangu** — its generated
   `hardware-configuration.nix` and `mySystem.performance.noatime` both add it.
   gonggong needs the option, so it cannot simply be deleted.
8. **Monitor layout gating has two formulas.** HM `desktop/hyprland/settings.nix`
   writes `monitor`/`workspace_rule`, and `desktop/hyprland/default.nix` derives
   `monitors.primary_workspaces` for `share/hypr/primary.lua`; the two must
   agree but are not tested together.
9. **Shader output is not freshness-checked.** `pkgs/pangu` only verifies each
   `.frag`/`.vert` has a `.qsb`; editing a shader without
   `pkgs/pangu/rebake-shaders.sh` ships a stale effect and passes CI.
10. **Some shelled-out commands are not pinned.** `faillock` (lock screen),
    `nvidia-smi`, `nmcli`, `bluetoothctl`, `hyprpicker`, `playerctl` resolve
    through the session PATH that `pangu` retains, not `runtimeInputs`.
11. **Lock screen has dead paths.** `failLockCheck` is never started (the
    fail-lock countdown is unreachable), `errorMessage` is never displayed,
    `hostnameProc` is unused, and `ScreencopyView` is drawn under the wallpaper.
12. **Remaining tab copy-paste.** The list tabs still each define
    `adjustScrollForExpandedItem`, `clearSearch`, `updateFiltered*` and
    enter/cancel wrappers, and the settings panels still carry local
    `NumberInputRow`/`TextInputRow`/`PrefixRow`/`DecimalInputRow` copies.
