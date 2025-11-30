{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$character";
      right_format = "$cmd_duration";
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      directory = {
        style = "bold lavender";
        truncation_length = 4;
      };
      git_branch = {
        style = "bold mauve";
        format = "[$symbol$branch]($style) ";
      };
      cmd_duration = {
        format = "[$duration]($style)";
        style = "yellow";
      };
    };
  };

  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = "11";
      adjust_line_height = "120%";
      window_padding_width = 10;
      confirm_os_window_close = 0;
    };
  };
}
