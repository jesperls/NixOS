{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$nix_shell$character";
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
      git_status = {
        style = "bold yellow";
        format = "[$all_status$ahead_behind]($style) ";
      };
      nix_shell = {
        format = "[$symbol$state]($style) ";
        symbol = "❄️ ";
        style = "bold blue";
      };
      cmd_duration = {
        format = "[$duration]($style)";
        style = "yellow";
        min_time = 2000;
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
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ];
    colors = {
      fg = "#e6e3e8";
      bg = "#0f1117";
      hl = "#d47fa6";
      "fg+" = "#e6e3e8";
      "bg+" = "#191b21";
      "hl+" = "#e3b17a";
      info = "#b3adb9";
      prompt = "#d47fa6";
      pointer = "#e3b17a";
      marker = "#d47fa6";
      spinner = "#d47fa6";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    config = {
      global = {
        warn_timeout = "30s";
        hide_env_diff = true;
      };
    };
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
      
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = true;
      
      scrollback_lines = 10000;
      
      url_style = "curly";
      open_url_with = "default";
      detect_urls = true;
      
      enable_audio_bell = false;
      visual_bell_duration = "0.0";
      
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
    };
    keybindings = {
      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+shift+n" = "new_os_window_with_cwd";
    };
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
      style = "numbers,changes,header";
      italic-text = "always";
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "dracula";
      theme_background = false;
      vim_keys = true;
      rounded_corners = true;
      update_ms = 1000;
    };
  };
}
