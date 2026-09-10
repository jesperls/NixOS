{
  config,
  osConfig,
  ...
}:

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
        XDG_WALLPAPERS_DIR = osConfig.mySystem.desktop.shell.wallpapers;
        XDG_PROJECTS_DIR = "${homeDir}/Projects";
        XDG_GAMES_DIR = "${homeDir}/Games";
      };
    };

  };

  home.file = {
    "Pictures/Screenshots/.keep".text = "";
    "Pictures/Wallpapers/.keep".text = "";
    "Projects/.keep".text = "";
    "Games/.keep".text = "";
  };
}
