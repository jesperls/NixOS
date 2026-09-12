{
  shellVersion ? "dev",
}:

final: prev: {
  ttf-phosphor-icons = final.callPackage ./ttf-phosphor-icons { };
  pangu = final.callPackage ./pangu { version = shellVersion; };
  autofdo = final.callPackage ./autofdo { };
  # gsr maps the linked ffmpeg's libavcodec major to its NVENC API floor:
  # ffmpeg 9 (63) wants API 13.1 / driver 610, stable here is 595 (API 13.0).
  gpu-screen-recorder = prev.gpu-screen-recorder.override { ffmpeg = prev.ffmpeg_8; };
}
