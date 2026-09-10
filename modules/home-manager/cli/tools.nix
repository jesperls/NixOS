{
  osConfig,
  ...
}:

let
  colors = osConfig.mySystem.theme.colors;
in
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$nix_shell$character";
      right_format = "$cmd_duration";
      character = {
        success_symbol = "[➜](bold ${colors.accent2})";
        error_symbol = "[✗](bold ${colors.accent})";
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
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      global = {
        warn_timeout = "30s";
        hide_env_diff = true;
      };
    };
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "ansi";
      style = "numbers,changes,header";
      italic-text = "always";
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "Default";
      theme_background = false;
      vim_keys = true;
      rounded_corners = true;
      update_ms = 1000;
    };
  };
}
