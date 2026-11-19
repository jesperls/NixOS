_: prev:
{
  vesktop = prev.vesktop.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./vesktop-h264-payload-type.patch ]; # Chromium 156 varies H.264 PTs across m-sections (Vencord/Vesktop#1393).
  });
}
// import ./emulators.nix { pkgs = prev; }
