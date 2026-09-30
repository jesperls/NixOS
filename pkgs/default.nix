_: prev:
{
  gpu-screen-recorder = prev.gpu-screen-recorder.override { ffmpeg = prev.ffmpeg_8; }; # ffmpeg 9 requires NVENC API 13.1; the stable driver provides 13.0.
}
// import ./emulators.nix { pkgs = prev; }
