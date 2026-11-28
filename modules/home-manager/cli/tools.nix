{
  osConfig,
  pkgs,
  ...
}:

let
  colors = osConfig.mySystem.theme.colors;
  shellManaged = osConfig.mySystem.desktop.shell.enable;
  accent = if shellManaged then "blue" else colors.accent;
  accent2 = if shellManaged then "cyan" else colors.accent2;
  muted = if shellManaged then "bright-black" else colors.muted;
in
{
  home.packages = with pkgs; [
    fd
    ripgrep
    yq
    unzip
    zip
    fastfetch
    herdr-core
  ];

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$nix_shell$character";
      right_format = "$cmd_duration";
      character = {
        success_symbol = "[➜](bold ${accent2})";
        error_symbol = "[✗](bold ${accent})";
      };
      directory = {
        style = "bold ${accent}";
        truncation_length = 4;
      };
      git_branch = {
        style = "bold ${accent2}";
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
        style = "${muted}";
        min_time = 2000;
      };
    };
  };

  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
    extraOptions = [ "--group-directories-first" ];
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
    fileWidget = {
      command = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
      options = [
        "--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
      ];
    };
    changeDirWidget = {
      command = "fd --type d --strip-cwd-prefix --hidden --follow --exclude .git";
      options = [
        "--preview 'eza --tree --level=2 --color=always --icons=always {}'"
      ];
    };
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ];
    colors =
      if shellManaged then
        {
          fg = "-1";
          bg = "-1";
          hl = "4";
          "fg+" = "15";
          "bg+" = "0";
          "hl+" = "6";
          info = "8";
          prompt = "4";
          pointer = "6";
          marker = "4";
          spinner = "4";
        }
      else
        {
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

  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
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
    package = if osConfig.mySystem.hardware.nvidia.enable then pkgs.btop-cuda else pkgs.btop;
    settings = {
      color_theme = "Default";
      theme_background = false;
      vim_keys = true;
      rounded_corners = true;
      update_ms = 1000;
    };
  };
}
