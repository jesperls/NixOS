# Settings ownership inventory

This is a source-level map of the existing settings families, not a claim that every control works. The next implementation milestone is to make persistence and Nix override behavior visible in the panel before adding more controls.

Paths below are relative to `share/shell`. Pangu configuration files live under `$XDG_CONFIG_HOME/pangu/config`; its data files live under `$XDG_DATA_HOME/pangu` (with the normal XDG fallbacks).

| Settings family | Entry point | Backend and persistence | Apply behavior / next verification |
| --- | --- | --- | --- |
| Audio devices and stream volume | `modules/widgets/dashboard/controls/AudioMixerPanel.qml` | Quickshell PipeWire API; PipeWire/WirePlumber own device state | Live; verify default-device selection, profiles, unplug and restore |
| Wi-Fi | `modules/widgets/dashboard/controls/WifiPanel.qml` | `modules/services/NetworkService.qml`, Quickshell Networking | Live; verify failed authentication, connection persistence and reconnect |
| Bluetooth | `modules/widgets/dashboard/controls/BluetoothPanel.qml` | `modules/services/BluetoothService.qml`, Quickshell Bluetooth | Live; verify adapter selection, pairing and reconnect |
| Audio effects | `modules/widgets/dashboard/controls/EasyEffectsPanel.qml` | `modules/services/EasyEffectsService.qml`; EasyEffects socket and its own presets | Live; test disconnect/reconnect and responses to rapid commands |
| Theme and color variants | `modules/widgets/dashboard/controls/ThemePanel.qml` | `config/Config.qml`, `theme.json`, theme services | Live; verify exports and reload in each application/toolkit |
| Borders, gaps, shadows and blur | `modules/widgets/dashboard/controls/CompositorPanel.qml` | `compositor.json`; `modules/services/CompositorTheme.qml` generates data file `hyprland.lua` | Live plus compositor reload; verify generated values and reload failures |
| Bar, dock, overview, launcher and other shell presentation | `modules/widgets/dashboard/controls/ShellPanel.qml` | Corresponding adapters in `config/Config.qml` | Live; validate controls individually and on both monitors |
| Prefixes, weather and presentation performance | `modules/widgets/dashboard/controls/SystemPanel.qml` | `prefix.json`, `weather.json`, `performance.json`; consuming services | Live; distinguish visual effects from actual system tuning |
| Idle, lock and suspend policy | `modules/widgets/dashboard/controls/SystemPanel.qml` | `system.json`; `modules/services/IdleService.qml` generates hypridle configuration | Live regeneration; verify sleep/lock ordering and inhibitors on hardware |
| Day/night theme and night light | `modules/widgets/dashboard/controls/SystemPanel.qml` | `system.json`; AutoThemeService and NightLightService | Live; verify schedules, location changes and external gamma tools |
| Pomodoro preferences | `modules/widgets/dashboard/controls/SystemPanel.qml` | `system.json` | Trace timer lifecycle and media integration before claiming coverage |
| Pinned applications | `config/Config.qml` pinnedapps adapter | Data file `pinnedapps.json`, separate from configuration directory | Verify taskbar/launcher actions and desktop-entry identity |
| Nix-provided shell overrides | `modules/home-manager/desktop/shell.nix` in repo root | `mySystem.desktop.shell.settings`; generated startup merge | Reapplied on every shell start, including service restarts; removing an override leaves its last persisted value |
| Hardware, kernel, packages and service availability | Host and NixOS/Home Manager modules | Nix configuration | Rebuild/activation; no generic live editor currently provided |
| Monitor arrangement and input/layout defaults | Host monitor configuration and desktop options | Nix-generated Hyprland configuration | Inventory runtime support before introducing a persistent live editor |

## Findings and decisions

- Nix startup overrides and GUI edits currently share the same files. The merge preserves unrelated fields, and the settings page now lists the affected paths in a shared restart notice. Individual controls do not yet carry indicators.
- Removing a Nix override does not restore an earlier GUI value or schema default. This is the current merge contract, not a reset mechanism.
- Keep system-service state in its upstream backend. Do not copy volume, connection credentials or pairing state into Pangu JSON to make a universal settings store.
- Compositor appearance has a generated Lua output. Treat that file as derived output; the JSON adapter is the editable source. Runtime commands from other tools need explicit arbitration if they modify the same properties.
- Settings search now uses one explicit catalogue, including 128 control entries migrated from panel labels. Hidden panel loading and runtime crawling have been removed. New controls should add their label, keywords and navigation target to SettingsIndex.qml.
- EasyEffects uses positional socket replies and resets its reply index for each query. Overlapping queries and reconnect behavior need a protocol test before changing that implementation.

## Override visibility implementation

Nix now supplies a read-only metadata file containing overridden leaf paths, without their values. The settings page lists relevant paths in a scrollable restart notice on the corresponding configuration page; upstream service pages do not show unrelated shell overrides. It preserves temporary editing and the existing merge contract. Without metadata, the notice is hidden.

Lightweight checks passed for QML syntax, Nix parsing, nested paths, array leaves and empty overrides. Full flake and Pangu system builds passed after activation. The running service has the metadata environment variable and an empty override list. Visible-notice and multi-monitor interaction checks remain outstanding. Per-control indicators remain future work.

Acceptance checks: nested overrides identify only affected fields; absent metadata works for standalone Pangu; removing an override clears its indicator; values remain editable; restart behavior matches the indication; both monitors show the same metadata. Follow with a control-by-control inventory of System and Compositor, including validation, errors and runtime consumers.
