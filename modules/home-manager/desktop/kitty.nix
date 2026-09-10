{
  lib,
  osConfig,
  ...
}:

let
  colors = osConfig.mySystem.theme.colors;
  theme = osConfig.mySystem.theme;
in
{
  programs.kitty = {
    enable = true;
    settings = {
      font_family = theme.fonts.monospace;
      font_size = builtins.toString theme.fonts.size;
      modify_font = "cell_height 120%";
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
    # Last directive wins; the shell rewrites this with the wallpaper palette.
    extraConfig = lib.optionalString osConfig.mySystem.desktop.shell.enable "include ~/.cache/pangu/kitty.conf";
  };
}
