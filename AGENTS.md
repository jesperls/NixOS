# Working on this repo

Read `docs/configuration.md` before adding a mechanism, and `docs/desktop.md`
for desktop changes. If a change alters the documented structure or ownership,
update the documentation first.

## Structure & ownership

- **Hosts**: `hosts/pangu` (AMD CPU + NVIDIA GPU desktop running Hyprland Lua and Pangu shell) and `hosts/gonggong` (headless Intel server). Assembled in `nix/hosts.nix`.
- **Bundles**: `modules/nixos/bundle.nix` + `modules/home-manager/bundle.nix` (all hosts); `modules/nixos/desktop/bundle.nix` + `modules/home-manager/desktop/bundle.nix` (desktop hosts). Host-specific features are explicit imports in `hosts/<name>/`.
- **Options**: Prefer native NixOS/Home Manager options. Add `mySystem.*` options (`modules/nixos/options/`) only for cross-module coordination; Home Manager reads them via `osConfig.mySystem`. Modules must never import host files or branch on hostnames.
- **Pangu-Shell boundary**: Shell QML, Hyprland Lua (`hyprland/pangu`), shaders, and reusable Nix/HM modules live in `github:jesperls/Pangu-Shell` (local checkout: `/home/jesperls/Source/Pangu-Shell`). Edit, test, commit, and push there first, then run `nix flake update pangu-shell` here. Never commit `file://` or local path flake URLs — CI and Garnix evaluate from GitHub.
- **Generated & frozen state**:
  - `hosts/pangu/hardware-configuration.nix` is generated — never edit it.
  - `system.stateVersion` and `home.stateVersion` stay at host initialization values — never bump them.
  - `~/.config/hypr/{hyprland.lua,pangu/generated.lua}`, `~/.local/share/pangu/*.lua`, and `~/.cache/pangu/*` are generated outputs — edit their Nix or Pangu sources instead.

## Comments

Comment only what the code cannot say itself: traps, ordering constraints,
magic constants, and workarounds whose reason is not visible locally. One line,
at the point of confusion — prefer a line-end comment on the offending line.

Do not write:

- rationale essays, architecture notes, ownership boundaries, file headers
- explanations of what was removed, replaced or deprecated
- restatements of what the next line already says
- multi-line blocks where one clause would do
- nix option `description` strings longer than a sentence

Rationale for a change belongs in the chat reply, not the file.

If code needs prose to be readable, prefer renaming or restructuring. If it
still needs a note after that, write the note — a real trap left undocumented
is worse than a comment.

Never comment `#!` shebangs or `//@ pragma` lines away; they are load-bearing.

## Verify before claiming

Run all three before claiming a change is ready:

```sh
nix fmt -- --ci
nix flake check -L
nix build --no-link .#checks.x86_64-linux.pangu-system
```

Use `--no-link` on ad-hoc `nix build` invocations so `result*` symlinks do not clutter the worktree.
`nix flake check` evaluates and builds both host systems, Hyprland/Lua contracts, and backup/font-cache checks; the Pangu input gates on JS/Python tests, shader compilation, and `qmllint`.

Building is not switching. Never run `snis`, `snus`, `snub`, or `nixos-rebuild switch` — activation is the user's call. Do not commit or push unless asked.
