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
      setSessionVariables = true;
      desktop = "${homeDir}/Desktop";
      documents = "${homeDir}/Documents";
      download = "${homeDir}/Downloads";
      music = "${homeDir}/Music";
      pictures = "${homeDir}/Pictures";
      publicShare = "${homeDir}/Public";
      projects = "${homeDir}/Projects";
      templates = "${homeDir}/Templates";
      videos = "${homeDir}/Videos";
      extraConfig = {
        SCREENSHOTS = "${homeDir}/Pictures/Screenshots";
        WALLPAPERS = osConfig.mySystem.desktop.shell.wallpapers;
        GAMES = "${homeDir}/Games";
      };
    };
  };

  xdg.configFile."xfce4/helpers.rc".text = ''
    TerminalEmulator=${osConfig.mySystem.defaultApps.terminal.command}
    TerminalEmulatorDismissed=true
  '';
}
