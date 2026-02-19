{
  config,
  pkgs,
  osConfig,
  lib,
  ...
}:

let
  colors = osConfig.mySystem.theme.colors;
  theme = osConfig.mySystem.theme;
  removeHash = builtins.replaceStrings [ "#" ] [ "" ];
in
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
        style = "bold ${colors.accent}";
        truncation_length = 4;
      };
      git_branch = {
        style = "bold ${colors.accent2}";
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
        style = "${colors.muted}";
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
      fg = colors.text;
      bg = colors.background;
      hl = colors.accent;
      "fg+" = colors.text;
      "bg+" = colors.surface;
      "hl+" = colors.accent2;
      info = colors.muted;
      prompt = colors.accent;
      pointer = colors.accent2;
      marker = colors.accent;
      spinner = colors.accent;
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
    settings = {
      font_family = theme.fonts.monospace;
      font_size = builtins.toString theme.fonts.size;
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

      foreground = colors.text;
      background = colors.background;
      selection_foreground = colors.background;
      selection_background = colors.accent;
      cursor = colors.accent;
      cursor_text_color = colors.background;
      url_color = colors.accent2;
      active_border_color = colors.accent;
      inactive_border_color = colors.border;
      bell_border_color = colors.accent2;
      active_tab_foreground = colors.background;
      active_tab_background = colors.accent;
      inactive_tab_foreground = colors.muted;
      inactive_tab_background = colors.surface;
      tab_bar_background = colors.surfaceAlt;
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

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = osConfig.mySystem.user.fullName;
        email = osConfig.mySystem.user.email;
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.mpv = {
    enable = true;
    config = {
      gpu-api = "vulkan";
      hwdec = "auto-safe";
      vo = "gpu-next";
      profile = "gpu-hq";
    };
  };
}
