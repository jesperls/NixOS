{ config, ... }:

let
  homeDir = config.home.homeDirectory;
in
{
  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${homeDir}/Desktop";
      documents = "${homeDir}/Documents";
      download = "${homeDir}/Downloads";
      music = "${homeDir}/Music";
      pictures = "${homeDir}/Pictures";
      publicShare = "${homeDir}/Public";
      templates = "${homeDir}/Templates";
      videos = "${homeDir}/Videos";
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${homeDir}/Pictures/Screenshots";
        XDG_WALLPAPERS_DIR = "${homeDir}/Pictures/Wallpapers";
        XDG_PROJECTS_DIR = "${homeDir}/Projects";
        XDG_GAMES_DIR = "${homeDir}/Games";
      };
    };

    cacheHome = "${homeDir}/.cache";
    configHome = "${homeDir}/.config";
    dataHome = "${homeDir}/.local/share";
    stateHome = "${homeDir}/.local/state";
  };

  home.file = {
    "Pictures/Screenshots/.keep".text = "";
    "Pictures/Wallpapers/.keep".text = "";
    "Projects/.keep".text = "";
    "Games/.keep".text = "";
  };

  xdg.configFile."xfce4/helpers.rc".text = ''
    TerminalEmulator=kitty
    TerminalEmulatorDismissed=true
  '';
}
