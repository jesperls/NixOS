{ lib, osConfig, ... }:

let
  apps = osConfig.mySystem.defaultApps;

  browserTypes = [
    "text/html"
    "application/xhtml+xml"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/about"
    "x-scheme-handler/unknown"
    "x-scheme-handler/chrome"
    "x-scheme-handler/ftp"
  ];

  editorTypes = [
    "text/x-readme"
    "text/markdown"
    "text/x-markdown"
    "text/x-python"
    "text/x-shellscript"
    "text/x-csrc"
    "text/x-chdr"
    "text/x-c++src"
    "text/x-c++hdr"
    "text/javascript"
    "text/css"
    "text/xml"
    "application/xml"
    "application/json"
    "application/x-yaml"
    "text/x-yaml"
    "application/x-shellscript"
  ];

  textEditorTypes = [
    "text/plain"
    "text/x-log"
    "application/x-desktop"
  ];

  imageTypes = [
    "image/jpeg"
    "image/jpg"
    "image/png"
    "image/gif"
    "image/webp"
    "image/svg+xml"
    "image/bmp"
    "image/tiff"
  ];

  pdfTypes = [
    "application/pdf"
    "application/postscript"
  ];

  archiveTypes = [
    "application/zip"
    "application/x-rar-compressed"
    "application/x-tar"
    "application/x-bzip2"
    "application/gzip"
    "application/x-7z-compressed"
    "application/vnd.rar"
    "application/x-compressed-tar"
    "application/x-bzip-compressed-tar"
    "application/x-xz"
    "application/x-xz-compressed-tar"
    "application/zstd"
    "application/x-zstd-compressed-tar"
  ];

  avTypes = [
    "audio/mpeg"
    "audio/ogg"
    "audio/wav"
    "audio/flac"
    "audio/aac"
    "audio/x-mp3"
    "video/mp4"
    "video/x-msvideo"
    "video/quicktime"
    "video/x-matroska"
    "video/webm"
    "video/ogg"
    "video/mpeg"
    "video/x-ms-wmv"
    "video/x-flv"
  ];

  assign = types: desktopFile: lib.genAttrs types (_: desktopFile);
in
{
  xdg.mimeApps = {
    enable = true;

    defaultApplications =
      assign browserTypes apps.browser.desktopFile
      // assign editorTypes apps.editor.desktopFile
      // assign textEditorTypes apps.textEditor
      // assign imageTypes apps.imageViewer
      // assign pdfTypes apps.pdfViewer
      // assign archiveTypes apps.archiveManager
      // assign avTypes apps.videoPlayer
      // {
        "inode/directory" = apps.fileManager.desktopFile;
        "x-scheme-handler/discord" = "discord.desktop";
        "x-scheme-handler/terminal" = apps.terminal.desktopFile;
        "application/x-terminal-emulator" = apps.terminal.desktopFile;
      };

    associations.added =
      assign browserTypes apps.browser.desktopFile
      // assign [
        "application/x-extension-htm"
        "application/x-extension-html"
        "application/x-extension-shtml"
        "application/x-extension-xhtml"
        "application/x-extension-xht"
      ] apps.browser.desktopFile;
  };
}
