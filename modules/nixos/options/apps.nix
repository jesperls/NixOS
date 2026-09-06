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

  mkHandler =
    description: desktopFile:
    lib.mkOption {
      type = lib.types.str;
      default = desktopFile;
      description = "Desktop file that handles ${description}, for MIME associations.";
    };
in
{
  options.mySystem.defaultApps = {
    terminal = mkApp "terminal emulator" "kitty" "kitty.desktop";
    browser = mkApp "web browser" "firefox" "firefox.desktop";
    fileManager = mkApp "file manager" "thunar" "thunar.desktop";
    editor = mkApp "code editor" "zeditor" "dev.zed.Zed.desktop";

    textEditor = mkHandler "plain text files" "org.gnome.gedit.desktop";
    imageViewer = mkHandler "image files" "imv.desktop";
    videoPlayer = mkHandler "video and audio files" "mpv.desktop";
    pdfViewer = mkHandler "PDF documents" "org.gnome.Evince.desktop";
    archiveManager = mkHandler "archives" "org.gnome.FileRoller.desktop";
  };
}
