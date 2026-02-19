{ config, pkgs, ... }:

{
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
      "x-scheme-handler/chrome" = "firefox.desktop";
      "x-scheme-handler/ftp" = "firefox.desktop";
      "x-scheme-handler/file" = "firefox.desktop";

      "text/plain" = "gedit.desktop";
      "text/x-readme" = "code.desktop";
      "text/markdown" = "code.desktop";
      "text/x-markdown" = "code.desktop";
      "text/x-python" = "code.desktop";
      "text/x-shellscript" = "code.desktop";
      "text/x-csrc" = "code.desktop";
      "text/x-chdr" = "code.desktop";
      "text/x-c++src" = "code.desktop";
      "text/x-c++hdr" = "code.desktop";
      "text/javascript" = "code.desktop";
      "text/css" = "code.desktop";
      "text/xml" = "code.desktop";
      "application/xml" = "code.desktop";
      "application/json" = "code.desktop";
      "application/x-yaml" = "code.desktop";
      "text/x-yaml" = "code.desktop";
      "text/x-log" = "gedit.desktop";
      "application/x-desktop" = "gedit.desktop";
      "application/x-shellscript" = "code.desktop";

      "image/jpeg" = "imv.desktop";
      "image/jpg" = "imv.desktop";
      "image/png" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/svg+xml" = "imv.desktop";
      "image/bmp" = "imv.desktop";
      "image/tiff" = "imv.desktop";

      "application/pdf" = "evince.desktop";
      "application/postscript" = "evince.desktop";

      "application/zip" = "file-roller.desktop";
      "application/x-rar-compressed" = "file-roller.desktop";
      "application/x-tar" = "file-roller.desktop";
      "application/x-bzip2" = "file-roller.desktop";
      "application/gzip" = "file-roller.desktop";
      "application/x-7z-compressed" = "file-roller.desktop";

      "audio/mpeg" = "mpv.desktop";
      "audio/ogg" = "mpv.desktop";
      "audio/wav" = "mpv.desktop";
      "audio/flac" = "mpv.desktop";
      "audio/aac" = "mpv.desktop";
      "audio/x-mp3" = "mpv.desktop";

      "video/mp4" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/ogg" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";
      "video/x-ms-wmv" = "mpv.desktop";
      "video/x-flv" = "mpv.desktop";

      "inode/directory" = "thunar.desktop";

      "x-scheme-handler/discord" = "vesktop.desktop";

      "x-scheme-handler/terminal" = "kitty.desktop";
      "application/x-terminal-emulator" = "kitty.desktop";
    };

    associations.added = {
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "text/html" = "firefox.desktop";
      "application/x-extension-htm" = "firefox.desktop";
      "application/x-extension-html" = "firefox.desktop";
      "application/x-extension-shtml" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      "application/x-extension-xhtml" = "firefox.desktop";
      "application/x-extension-xht" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
      "x-scheme-handler/chrome" = "firefox.desktop";
      "x-scheme-handler/ftp" = "firefox.desktop";
      "x-scheme-handler/file" = "firefox.desktop";
    };
  };
}
