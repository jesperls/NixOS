{ config, pkgs, ... }:

{
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      # Web browsers and URLs
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
      "x-scheme-handler/chrome" = "firefox.desktop";
      "x-scheme-handler/ftp" = "firefox.desktop";
      "x-scheme-handler/file" = "firefox.desktop";

      # Text files and code
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

      # Images
      "image/jpeg" = "feh.desktop";
      "image/jpg" = "feh.desktop";
      "image/png" = "feh.desktop";
      "image/gif" = "feh.desktop";
      "image/webp" = "feh.desktop";
      "image/svg+xml" = "feh.desktop";
      "image/bmp" = "feh.desktop";
      "image/tiff" = "feh.desktop";

      # PDFs
      "application/pdf" = "evince.desktop";
      "application/postscript" = "evince.desktop";

      # Office documents (fallback to firefox)
      "application/vnd.oasis.opendocument.text" = "libreoffice-writer.desktop";
      "application/vnd.oasis.opendocument.spreadsheet" =
        "libreoffice-calc.desktop";
      "application/vnd.oasis.opendocument.presentation" =
        "libreoffice-impress.desktop";
      "application/msword" = "libreoffice-writer.desktop";
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
        "libreoffice-writer.desktop";
      "application/vnd.ms-excel" = "libreoffice-calc.desktop";
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" =
        "libreoffice-calc.desktop";
      "application/vnd.ms-powerpoint" = "libreoffice-impress.desktop";
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
        "libreoffice-impress.desktop";

      # Archives
      "application/zip" = "file-roller.desktop";
      "application/x-rar-compressed" = "file-roller.desktop";
      "application/x-tar" = "file-roller.desktop";
      "application/x-bzip2" = "file-roller.desktop";
      "application/gzip" = "file-roller.desktop";
      "application/x-7z-compressed" = "file-roller.desktop";

      # Audio
      "audio/mpeg" = "rhythmbox.desktop";
      "audio/ogg" = "rhythmbox.desktop";
      "audio/wav" = "rhythmbox.desktop";
      "audio/flac" = "rhythmbox.desktop";
      "audio/aac" = "rhythmbox.desktop";
      "audio/x-mp3" = "rhythmbox.desktop";

      # Video
      "video/mp4" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/ogg" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";
      "video/x-ms-wmv" = "mpv.desktop";
      "video/x-flv" = "mpv.desktop";

      # File manager
      "inode/directory" = "thunar.desktop";

      # Chat/Communication (Discord)
      "x-scheme-handler/discord" = "vesktop.desktop";
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
