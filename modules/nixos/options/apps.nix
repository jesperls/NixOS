{ lib, ... }:

let
  appType = lib.types.submodule {
    options = {
      command = lib.mkOption {
        type = lib.types.str;
        description = "Command used to launch the application (keybinds, env vars).";
      };
      desktopFile = lib.mkOption {
        type = lib.types.str;
        description = "Desktop file name used for MIME associations.";
      };
    };
  };

  mkApp =
    description: command: desktopFile:
    lib.mkOption {
      type = appType;
      default = { inherit command desktopFile; };
      description = "Default ${description}.";
    };
in
{
  options.mySystem.defaultApps = {
    terminal = mkApp "terminal emulator" "kitty" "kitty.desktop";
    browser = mkApp "web browser" "firefox" "firefox.desktop";
    fileManager = mkApp "file manager" "thunar" "thunar.desktop";
    editor = mkApp "code editor" "zeditor" "dev.zed.Zed.desktop";
    textEditor = mkApp "plain text editor" "gedit" "gedit.desktop";
    imageViewer = mkApp "image viewer" "imv" "imv.desktop";
    videoPlayer = mkApp "video player" "mpv" "mpv.desktop";
    pdfViewer = mkApp "PDF viewer" "evince" "evince.desktop";
    archiveManager = mkApp "archive manager" "file-roller" "file-roller.desktop";
  };
}
