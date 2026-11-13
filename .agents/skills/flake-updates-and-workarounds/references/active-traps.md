# Load-Bearing Traps & Hardware Invariants

Do **not** delete these during cleanup passes unless the underlying hardware, kernel, or upstream architecture has changed and been verified live.

## Audio & PipeWire
- **PipeWire X11 bell disabled** (`modules/nixos/services/audio.nix`): `"module.x11.bell" = false` prevents `mod.x11-bell` from segfaulting PipeWire when Xwayland exits.
- **WebRTC / Chromium Pulse regex** (`modules/nixos/services/audio.nix`): Anchored `~^(WEBRTC VoiceEngine|Chromium.*)$` forces 1024/48000 quantum so voice streams do not underrun.
- **Focusrite Scarlett 2i2 4th Gen & Logitech A50** (`hosts/pangu/audio.nix`):
  - Udev rule `90-usb-audio-power.rules` forces `ATTR{power/control}="on"` on Focusrite USB (`1235`) to stop autosuspend dropouts.
  - WirePlumber matches both `node.name` and `alsa.long_card_name` (needed to catch UCM SplitPCM's internal `alsa_input.hw_Gen_0` node), disables ALSA batch mode (`api.alsa.disable-batch = true`), sets `session.suspend-timeout-seconds = 0`, and enables `device.recover-on-error = true`.

## NVIDIA & Wayland
- **Suspend VRAM temp path** (`modules/nixos/hardware/nvidia.nix`): `NVreg_TemporaryFilePath=/var/tmp` is required because `/tmp` is `tmpfs` (50% RAM) and NVIDIA suspend/resume fails if VRAM backing fills `/tmp`.
- **Firefox VA-API on NVIDIA & Wayland session restore** (`modules/home-manager/programs/firefox.nix`): Scopes `MOZ_DISABLE_RDD_SANDBOX=1` to the Firefox wrapper when `mySystem.hardware.nvidia.enable` is true so `nvidia-vaapi-driver` can load inside the decoder process, and sets `browser.sessionstore.max_resumed_crashes = -1` because Wayland compositor teardown exits GTK before Firefox writes a clean shutdown checkpoint.
- **Sunshine Wayland capture** (`modules/nixos/services/sunshine.nix`): Forces `capture=wlr` on the `ExecStart` CLI with `capSysAdmin = false` so Hyprland direct capture works without portal prompts while keeping `~/.config/sunshine` editable via the web UI.

## Storage, Swap & Memory
- **Btrfs `/swap` subvolume** (`hosts/pangu/configuration.nix`): Swap lives at `/swap/swapfile` inside a dedicated subvolume (`mkswap-swap-swapfile` ordered `after = [ "systemd-remount-fs.service" ]`) so active swap never blocks root Btrfs snapshots.
- **zram + zswap exclusion** (`modules/nixos/core/boot.nix`): Passes `zswap.enabled=0` whenever `zram` is enabled to prevent double-compressing pages before hitting zram.
- **Desktop earlyoom swap threshold** (`hosts/pangu/configuration.nix`): Sets `freeSwapThreshold = 100` so earlyoom acts when free RAM drops below 5% rather than waiting for 40 GiB of disk swap to thrash.

## Devices, Permissions & Sandboxing
- **NuPhy HID udev ordering** (`hosts/pangu/configuration.nix`): `70-nuphy.rules` (`TAG+="uaccess"` for vendor `19f5`) must be numbered `< 73` so systemd's `73-seat-late.rules` applies active-seat ACLs without adding the user to the privileged `input` group.
- **miniDLNA supplementary groups** (`modules/nixos/services/dlna.nix`): `PrivateUsers = lib.mkForce false` is required because systemd user namespaces drop supplementary group `users`, breaking media directory access.
- **Hyprcursor extraction** (`modules/home-manager/desktop/theme.nix`): Repacks `bibata-cursors` into a native `hyprcursor` theme (`hyprcursorTheme`) so Hyprland uses crisp vector/native cursors matching `XCURSOR_THEME`.

## Desktop Apps & Emulators
- **Vesktop Vencord updates** (`modules/home-manager/programs/vesktop.nix`): Avoid `vencord.useSystem = true` with `autoUpdate = false`; Discord web rollouts frequently break older nixpkgs-pinned Vencord builds and render a blank window until Vencord updates.
- **Emulator wrappers** (`pkgs/emulators.nix`):
  - `melonds`: `GDK_BACKEND=x11` works around Wayland surface/GL issues.
  - `xemu`: `SDL_JOYSTICK_HIDAPI=0` avoids duplicate/broken controller input under SDL HIDAPI.
