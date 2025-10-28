{ config, pkgs, userConfig, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      ".." = "cd ..";
      snis =
        "sudo nixos-rebuild switch --flake ~/nixos-config#${userConfig.hostname}";
    };
    bashrcExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi
    '';
  };

  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = "11";
      adjust_line_height = 1;
    };
  };

  programs.wofi = {
    enable = true;
    style = builtins.readFile ../wofi/style.css;
    settings = {
      show = "drun";
      allow_images = true;
      prompt = "Search:";
    };
  };
}
