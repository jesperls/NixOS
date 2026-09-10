# Working on this repo

The design contract — layers, ownership, conventions, and known seams — is in
`docs/architecture.md`. Read it before adding a mechanism; if a change does not
fit it, change the document first.

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
`hosts/pangu/hardware-configuration.nix` is generated — leave it alone.

## Verify before claiming

`nix flake check` for evaluation, `nix build .#checks.x86_64-linux.pangu-system`
for the real thing. `pkgs/pangu` gates on qmllint, so a QML syntax error fails
the build instead of the shell at startup.

Building is not switching. `snis` is the user's call.
