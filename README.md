# nixos-config

NixOS and Home Manager for **pangu**, an AMD/NVIDIA desktop, and
**gonggong**, a headless server. Pangu also names the desktop's Quickshell shell.

## Use

Run these from the checkout:

```sh
nix flake check
nix build .#checks.x86_64-linux.pangu-system
```

The first command evaluates and builds all checks, including both hosts. The
second builds just the desktop system. Neither activates it. For evaluation
without builds, use `nix flake check --no-build`.

The configured zsh aliases use `$FLAKE`, set from `mySystem.paths.repoRoot`:

| Command | Action |
| --- | --- |
| `snis` | Build and switch |
| `snub` | Build for the next boot |
| `snus` | Update inputs, build and switch |
| `nfu` | Update inputs in the checkout |
| `snuf` | Clean generations, keeping `mySystem.system.keepGenerations` |

Pangu has a `fallback` boot specialisation with the stock kernel and sched_ext
disabled. Kernel changes take effect after rebooting.

## Working on the config

- [Configuration](docs/configuration.md): where changes belong and how hosts are assembled.
- [Desktop](docs/desktop.md): Hyprland, Pangu settings, development and debugging.
- [Kernel](docs/kernel.md): CachyOS build options and the fallback kernel.

Pangu lives in the separate [Pangu-Shell repository](https://github.com/jesperls/Pangu-Shell),
consumed through the pinned GitHub input in `flake.nix`. Commit and push shell
changes there, then run `nix flake update pangu-shell` here before rebuilding.
Its README documents standalone installation and development.
