_: prev:
{
  gpu-screen-recorder = prev.gpu-screen-recorder.override { ffmpeg = prev.ffmpeg_8; }; # ffmpeg 9 requires NVENC API 13.1; the stable driver provides 13.0.

  antigravity-cli = prev.antigravity-cli.overrideAttrs (old: {
    version = "1.3.4"; # Adds Gemini 4 models.
    src = prev.fetchurl {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.4-5524158944247808/linux-x64/cli_linux_x64.tar.gz";
      hash = "sha256-216B6N7nLSgssftfzZjcWkNoBzDXHj1jemfIdOwHetM=";
    };
    passthru = (old.passthru or { }) // {
      wholeVersion = "1.3.4-5524158944247808";
    };
  });
}
// import ./emulators.nix { pkgs = prev; }
