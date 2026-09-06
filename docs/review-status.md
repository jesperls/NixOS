# Configuration review coverage

Build success is not a subsystem audit or a performance measurement. “Targeted” means specific paths have been reviewed and tested; it does not mean the entire row is complete. Live checks refer to the installed system, not isolated test fixtures.

| Area | Source coverage | Evidence so far | Remaining work |
| --- | --- | --- | --- |
| Flake, packaging, dependencies | Targeted | System evaluation/builds, shell build checks | Scheduled nh cleanup now uses idle CPU/I/O scheduling and a 30-minute randomized timer delay (activated; see September 9 consolidation check); input/overlay audit, closure size, upgrade and rollback paths |
| Boot, storage, kernel, memory | Targeted | Reviewed tuning; both kernel configurations build | Boot/recovery, memory pressure, disk latency, trim and filesystem behavior |
| AutoFDO | Targeted | Collector validation and kernel/profile guards | Measure collection overhead and validate resulting profiles |
| Scheduling and power policy | Targeted | Read scheduler, ananicy, irqbalance and power-profile configuration; launcher profile actions now follow hardware capabilities, unsupported selections ignored; battery state waits for UPower readiness and uses its power-source state (activated; see September 9 consolidation check) | Measure foreground responsiveness under CPU/I/O load |
| NVIDIA and monitors | Targeted | Configuration builds; user confirmed settings placement fix | Hotplug, mixed refresh rates, VRR, DPMS, resume, GPU memory |
| Hyprland Lua | Targeted | Layout/session regression tests; centered-window fixes | Every binding/rule, fullscreen transitions, application matching |
| Session startup and portals | In progress | Read systemd autostarts and portal selection; live failed-unit check clean; isolated app survives launcher teardown in session-bound scope | Startup ordering, logout cleanup, failed-service recovery, portal routing |
| Authentication and lockscreen | Targeted | Lock IPC and auth-state fixes | Authentication failures, compositor crash, sleep/lock ordering on hardware |
| Idle and inhibitors | Targeted | hypridle ownership and generated-command tests | Real idle inhibition, suspend/resume, player and game interactions |
| Wallpaper rendering and caches | Targeted | Cache, shader, palette and process-ownership tests | Real video/Wallpaper Engine playback, hotplug, long-running resource use |
| Colors and application exports | Targeted | Native QML tests for palette reload and live edits | Actual GTK/Qt/terminal/browser reloads and application-specific rendering |
| Settings schema, drafts and persistence | Targeted | Search consolidated into explicit catalogue with 128 additional control entries; subsection targets inspected, multiword matching and empty state added; hidden panel indexer removed; settings navigation is per-panel and search changes resolve the selected destination even when its index stays the same; apply/discard coverage and independent draft tests; declarative schema path fixed and valid/invalid file names evaluated; generated override script tested for nested preservation, atomic writes, unchanged-file stability, permissions, malformed JSON and quoted paths | Nix override notice implemented with syntax/metadata checks; full build passed and active service metadata verified; visible-notice and multi-monitor checks pending; every control, invalid external edits, crash/restart persistence |
| Launcher, taskbar, desktop entries | In progress | GTK/GIO desktop/terminal launch tests; native usage-history persistence tests; shared app scopes | Pinned apps, actions, ranking and live workspace placement |
| Clipboard | Targeted | SQLite/content/FTS/pinning regression tests | Large-history latency, clipboard-manager interoperability |
| Notifications | Targeted | Per-notification timeout and expiry tests; history actions dismiss only their notification, restored history has no stale actions, missing handlers do not delete entries; saved history stays chronological so post-restart eviction removes oldest entries | Actions, grouping, persistence, app compatibility, multi-monitor behavior |
| Recording, replay and screenshots | Targeted | Recording argument and startup-race tests | Actual capture, encoder failure, replay save, region selection, output paths |
| Audio, MPRIS and EasyEffects | Targeted | Visualizer retries after unexpected exit with a delay and resets its failure latch when visualization becomes needed again (activated; see September 9 consolidation check); routing editor launches from mixer instead of login (no active patchbay configured); EasyEffects open/refresh remain accessible when disconnected | EasyEffects query coalescing activated and ten rapid native refreshes returned the correct presets; filtered MPRIS selection activated (player lifecycle still needs live coverage); device switching, profiles, hotplug and routing |
| Network and Bluetooth UI | Targeted | Wi-Fi scan lifecycle reviewed; Network page shows wired connectivity and missing Wi-Fi hardware; connected wired adapter preferred when several exist; Bluetooth discovery lifetime belongs to shared service, so panel/indexer destruction cannot interrupt another screen | Network applet moved to the upstream Home Manager service with StatusNotifier enabled; polkit agent also uses its upstream module, preserving restart policy (activated; applet registered in the tray); connection failures, credentials, adapter hotplug, suspend and discovery |
| Weather and day/night services | Targeted | Retry, schedule, draft and restart tests | Timezone/clock changes, sunrise availability, actual gamma control |
| Resource monitoring and brightness | Targeted | Sampling and DDC serialization fixes; metrics worker pauses across suspend/wake settling and retries after exit with a one-second delay (activated; see September 9 consolidation check) | Verify readings, per-monitor limits, polling cost, disconnected devices |
| Dashboard tools | Partial read | Shared Notes drafts and serialized atomic persistence; native conflict/concurrency tests; live edits on both monitors; tmux uses configured terminal | Notes rich-text formatting, crash-time draft recovery, large libraries; timers/calendars/links |
| OCR, QR, Lens, color picker | Targeted | Scanner/copy failure handling, literal content and cancellation regression tests; private color previews | Actual recognition, notification actions, Lens, binary QR payloads |
| Dock, overview, tray and panel widgets | Targeted | Monitor ownership/focus-grab fixes; native QML regression tests for overview bindings and screen registry; activated invocation has no QML runtime errors | Settings verified floating at 1000×760 with initial search focus on both monitors; bare window addresses normalized for Hyprland; overview opened on both screens; remaining keyboard/pointer flows, scaling, hotplug and resource use |
| Host networking, SSH and firewall | Partial read | Basic configuration inspected | Effective listeners, host-specific rules, remote recovery |
| Sunshine, DLNA and Flatpak | Targeted | DLNA uses upstream firewall ports; inotify enabled and running service config verified | Sunshine upstream device/library setup activated; H.264/HEVC/AV1 NVENC initialization confirmed; actual network discovery/media playback and streaming still need coverage |
| Docker, Ollama and Home Assistant | Targeted | Glances password-file credentials; local/remote/disabled configuration checks and real authenticated API test; MQTT enable/disable/re-enable preserves registration and missing password files fail before writing; Ollama uses upstream resource defaults and service-account management | Enabled-host behavior, resource limits and connectivity; Docker audit; Ollama inference and GPU-memory measurements |
| Browser, OBS, Discord, Spotify, Deltatune | Partial read | Application modules read; Firefox crash recovery restored and forced graphics overrides disabled; OBS acceleration follows host hardware | Generated settings, upstream module interactions, updates and startup |
| CLI, shell, SSH client and default apps | Partial read | Command lookup and comma now use flake-pinned nix-index-database packages instead of relying on a manually refreshed user cache (activated; see September 9 consolidation check); terminal environment and default-app options inspected; rebuild paths quoted; TTY1 desktop startup gated by host Hyprland enablement; GNOME desktop IDs corrected for text/PDF/archive defaults, compressed archives covered, blanket file-URI browser association removed (activated; MIME defaults verified) | Launcher failures now notify with the application name and repeated failures replace the prior notice; unused launcher output collection removed (activated; see September 9 consolidation check); remaining aliases, completion and application launch behavior |
| File manager, archives and removable storage | Targeted | Thunar archive wrapper and Tumbler plugin defaults inspected; File Roller dependency moved into the reusable file-manager module; redundant xfconf declaration removed because upstream Thunar enables it | Archive create/extract flows, removable-drive mount/eject, remote shares and thumbnail latency |
| Font, cursor and static theme setup | Partial read | Generated theme paths inspected | Cross-toolkit consistency, scale changes, fallback rendering |
| Gonggong host | Not audited independently | Configuration and fallback system build | Host-specific hardware, packages, services and actual runtime |

## Direction and next milestones

The target is a reproducible desktop whose shell integrates existing system services and owns only desktop presentation and interaction. Keep host facts in hosts, reusable policy in modules, and custom implementations only where upstream cannot provide the required behavior.

| Responsibility | Intended owner | Integration contract |
| --- | --- | --- |
| Hardware, packages, security and service availability | NixOS | Declarative options; rebuild required |
| User applications and session services | Home Manager and systemd | Explicit startup, shutdown and failure handling |
| Audio, networking, Bluetooth, power and media | Upstream services | Native APIs exposed through shared shell services |
| Live desktop preferences | Pangu settings | One schema, shared drafts, validated persistence and explicit Nix override behavior |
| Monitor-specific panels | Pangu views | Shared state with per-screen presentation; no duplicate backends |
| User documents and application data | Their owning application | Preserve across rebuilds; explicit recovery and deletion |

Next milestones, in order:

1. Continue the [settings ownership inventory](settings-ownership.md), starting with Nix override visibility. Map every existing settings control to its backend and persistence owner; identify missing controls, competing writers and settings that require rebuilding. Use this inventory before expanding the panel.
2. Complete session lifecycle and audio integration review, including logout cleanup, service recovery, device switching and both-monitor interactions.
3. Measure startup, idle shell CPU/memory and responsiveness under load; retain tuning only with evidence and a rollback path.
4. Audit remaining application modules and Gonggong independently, including optional service configurations that normal host builds do not exercise.

Each milestone should deliver a coherent user-visible outcome, relevant failure-path tests and recorded live evidence where hardware is involved. Small fixes remain useful when they remove blockers to these outcomes. The unresolved boot freeze remains tracked separately; retain the requested CachyOS kernel.

## Completion criteria

- Every area has a recorded source review and its unresolved findings addressed or explicitly retained with a reason.
- Tests exercise important failure paths, not just successful evaluation.
- Live checks cover both monitors, sleep/wake, application launches, settings changes and recovery.
- Performance claims include measurements; unmeasured choices remain baseline choices.

## Boot-freeze investigation (2026-09-07)

Intermittent apparent full-machine freezes occur around desktop startup; a forced power-off followed by another boot usually works. The previous boot's journal ends abruptly near early startup, with no recorded NVIDIA Xid, panic, or lockup diagnosis. This does not establish whether the kernel, GPU, compositor, or hardware is responsible.

A stock-kernel isolation test was proposed and built, but the user explicitly declined changing kernels. Activation was interrupted before switching, and all proposed host changes were removed. Keep CachyOS LTO. No freeze reproduction or reboot was attempted; no root cause has been established.

Next evidence, if it freezes again: whether SSH or Ctrl+Alt+F3 still responds, and the previous boot's kernel/session logs after recovery. Revisit relevant driver/kernel fixes when available, without changing kernels unless the user requests it. A successful build is not proof that the freeze is fixed.

## Desktop measurements (2026-09-08)

After activation, with settings closed and no build running, a 10-second sample of Pangu's main process used 12.3% of one CPU core and about 569 MiB RSS. This includes the current desktop appearance and background activity; it excludes child processes and GPU memory. It is a baseline, not evidence of an improvement or a leak.

Settings opened centered at 1000×760 on DP-1 and DP-2. Initial typing worked; searches for dock icon and blur opened their respective configuration pages. No settings values were changed during these checks.

## Maintenance observation (2026-09-09)

The September 7 nh-clean journal records 30.456 seconds of CPU over 47.196 seconds elapsed, 1.1 GiB peak memory, 1.9 GiB read and 542.9 MiB written. The previous unit had normal scheduling priority. The new unit follows the upstream Nix optimizer's idle CPU/I/O policy and spreads timer starts over 30 minutes. This does not guarantee an idle desktop or prevent all storage contention. No cleanup was triggered during this review; generation retention is unchanged.

## Consolidation check (2026-09-09)

After the user's snis, the running system and result both resolve to /nix/store/c62mrbrrssa5ljwynxjzxy3qbkj3ci13-nixos-system-pangu-26.11.20260907.dc5d91f. No system or user units are failed. Pangu, hyprpolkitagent and the upstream network-manager-applet service are active; the old networkmanagerapplet unit is inactive. NetworkManager appears in the StatusNotifier registry with --indicator enabled.

Live MIME queries select gedit for text, Evince for PDFs, File Roller for ZIP/compressed tar, and Thunar for directories. The active cleanup unit has Nice=19 and idle CPU/I/O scheduling. Settings opened floating at 1000×760 on both DP-1 and DP-2, then closed; focus returned to DP-1. No new QML errors appeared during these settings checks.

Startup still logs whitespace-only desktop-entry warnings (a matching whitespace-only line exists in valve-steamvr.desktop) and a Qt portal app-ID registration warning. Their functional impact is not established. Activation does not validate suspend, battery transitions, worker failure recovery in the live session, hotplug, recording, or the intermittent boot freeze. No reboot, suspend, cleanup, or further activation was performed in this pass.

## Fullscreen launcher fix

Explicitly opened notch panels now bypass fullscreen auto-hide, while hover and notification reveals remain suppressed when available-on-fullscreen is disabled. Previously the launcher could take keyboard focus while remaining invisible. The bar retains its own fullscreen hiding policy. Activation and live fullscreen verification are pending.

## Desktop color-scheme integration

Pangu now exports its light/dark choice to the desktop color-scheme preference through gsettings, including changes where palette CSS stays identical. Updates are serialized and successful duplicate writes are skipped. Home Manager leaves this preference to Pangu when shell palette integration is enabled. Applications that follow the system preference can respond; legacy GTK theme variants and applications forcing their own appearance are not covered by this change. Activated by the user; the live Settings portal reports dark mode, matching Pangu. A live light/dark transition and visual verification remain pending.

## Portal routing (2026-09-10)

Replaced the ineffective OpenURI backend selector with GTK AppChooser and FileChooser selectors. Both are advertised by the installed GTK backend; Hyprland remains first in the default backend list. Existing default fallback already selected GTK for these interfaces, so this corrects configuration intent rather than establishing a fix for a reproduced dialog failure. Activation is pending. Earlier session logs also show null-screen binding errors during screen teardown; monitor removal still needs a focused lifecycle review.

## Screen removal lifecycle

Bar, notch, dock and frame lookups now tolerate a removed screen; screen-dependent loaders and reservations disable when their screen disappears. Unified panels hide without a target and retain the name used for registration, allowing destruction cleanup after the screen object is gone. Cleanup checks ownership before removing registry entries so an old panel cannot unregister its replacement. These changes address observed null-screen binding errors; physical unplug/replug and suspend validation remain pending.

## Live consolidation (2026-09-10)

After activation, no system or user services are failed and both monitors are present. The current shell process has no logged QML binding errors; the desktop-entry and portal-registration warnings remain. With availableOnFullscreen=false, a temporary terminal was made genuinely fullscreen on DP-1. Calling pangu run launcher displayed the app drawer above it while the bar stayed hidden; typing gedit filtered the results, and Escape dismissed it. Synthetic Super events did not trigger the shortcut, so physical Super-key behavior remains unverified. The temporary terminal was closed. No monitor was disconnected and no suspend or reboot was triggered.
