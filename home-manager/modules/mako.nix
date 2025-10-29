{ config, pkgs, ... }:

{
  services.mako = {
    enable = true;

    settings = {
      background-color = "#1e1e2eee";
      text-color = "#cdd6f4";
      border-color = "#89b4fa";
      progress-color = "over #313244";

      border-size = 2;
      border-radius = 8;
      padding = "12";
      margin = "10";

      font = "JetBrainsMono Nerd Font 11";

      icon-path = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";
      max-icon-size = 48;

      default-timeout = 5000;

      width = 350;
      height = 150;

      anchor = "top-right";

      group-by = "app-name";

      format = "<b>%s</b>\\n%b";

      "urgency=low" = {
        background-color = "#1e1e2e99";
        border-color = "#6c7086";
        default-timeout = 3000;
      };

      "urgency=normal" = {
        background-color = "#1e1e2eee";
        border-color = "#89b4fa";
        default-timeout = 5000;
      };

      "urgency=high" = {
        background-color = "#1e1e2eff";
        border-color = "#f38ba8";
        text-color = "#f38ba8";
        default-timeout = 0;
      };
    };
  };
}
