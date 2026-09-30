# Configuration

## Hosts and modules

[flake.nix](../flake.nix) pins inputs and exposes systems, packages and checks.
[nix/hosts.nix](../nix/hosts.nix) assembles each system from its host
configuration, Home Manager and the package overlay.

Each host's `configuration.nix` selects modules and sets machine-specific
values. Its `home.nix` selects the user configuration; `packages.nix`, where
present, contains the user's package list. Disk configuration stays in
`hardware-configuration.nix`; pangu's copy is generated and should not be edited.

The NixOS [base bundle](../modules/nixos/bundle.nix) supplies shared boot,
network, user and performance policy. The
[desktop bundle](../modules/nixos/desktop/bundle.nix) adds the graphical stack.
Home Manager has corresponding [base](../modules/home-manager/bundle.nix) and
[desktop](../modules/home-manager/desktop/bundle.nix) bundles. Features needed
by only some hosts are explicit imports in those hosts.

Put reusable behaviour in `modules/nixos` or `modules/home-manager`. A short
host-specific setting can use the upstream option directly in the host file;
it does not need a module just to enable a service. Package patches, build
steps and command wrappers belong in [pkgs](../pkgs). Pangu QML, Lua, packaging
and reusable desktop integration live in the separate
[Pangu-Shell repository](https://github.com/jesperls/Pangu-Shell). This flake pins
its GitHub revision through the `pangu-shell` input; push shell changes before
updating that input. Machine-specific adapters remain in this repository.

Each host sets `system.stateVersion` in its system configuration and
`home.stateVersion` in its Home Manager configuration. Keep these at the
versions used to initialise the host rather than updating them with inputs.

Pangu's application shortcuts and media aliases live in its `home.nix`.
Shared modules provide the shell integration without selecting host applications.
Graphical compatibility libraries for `nix-ld` belong to the desktop bundle;
the base bundle supplies only the shared runtime libraries.

Pangu grants active-session HID access to NuPhy devices through an early udev
rule, before systemd assigns seat permissions. It does not require membership
in the `input` group.

## Shared options

`mySystem` carries values used across modules: identity, monitors, default
applications, theme choices and desktop behaviour. The cross-cutting option
definitions are in [modules/nixos/options](../modules/nixos/options).
Feature-specific options live with their implementation, such as
[kernel.nix](../modules/nixos/performance/kernel.nix).

Use a native NixOS or Home Manager option when it already expresses the setting.
Add a `mySystem` option when consumers need a shared value or coordinated
behaviour. An `enable` option is useful when another module reads it as a
capability; an explicitly imported feature does not need its own enable switch.

Modules receive flake inputs through `specialArgs.inputs`. Home Manager uses
`osConfig` to read system options. Modules must not import a host file or
depend on a particular host name.

Desktop settings cross into mutable runtime state. The exact boundary is
documented in [Desktop](desktop.md): monitors and application choices come
from Nix; wallpaper colours and window decorations come from Pangu.

## Adding a host

Create `hosts/<name>/configuration.nix`, its hardware configuration and
`home.nix`. Import the base bundles, then the desktop bundles if needed.
Connect `home.nix` through `home-manager.users.<username>.imports`, as the
existing hosts do. Add `<name> = { };` in [nix/hosts.nix](../nix/hosts.nix).
Set the host's identity and state versions explicitly.

The host will then have a `nixosConfigurations.<name>` output and a
`checks.x86_64-linux.<name>-system` build.

## Verification

Run `nix fmt -- --ci` and `nix flake check` before considering a change ready.
For desktop changes, also build `.#checks.x86_64-linux.pangu-system` explicitly.
[checks.nix](../checks.nix) defines both system builds, monitor-generation and
generated-Lua checks, Pangu's upstream Lua check, backup rotation, and Flatpak
font-cache invalidation.

The Pangu flake owns the shell tests and runtime-command check. Building Pangu
runs its JavaScript and Python tests, checks shell scripts and
QML syntax, and compiles and validates shaders. The QML gate catches syntax
errors; it does not prove that every binding or visual interaction works.
Session behaviour still needs a check after activation.

Pangu keeps disk swap in the `/swap` Btrfs subvolume so active swap does not
prevent root snapshots. The swap initialisation service creates the subvolume
before creating its file. When migrating from `/swapfile`, confirm that
`/swap/swapfile` is active with `swapon --show`, then deactivate the old file
if it is still active and remove it. Building alone does not migrate swap.

Flatpak font caches are cleared on activation only when the managed system
fonts or their Fontconfig configuration change.

With zram enabled, boot disables zswap to avoid stacking compressed swap
layers. Pangu's earlyoom policy acts below 5% available memory without waiting
for disk swap to fill; the server retains the shared memory-and-swap policy.

[GitHub CI](../.github/workflows/check.yml) checks formatting, evaluates the
flake and builds the lightweight configuration checks.
[Garnix](../garnix.yaml) builds all flake checks, including the systems.
