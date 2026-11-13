{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  colors = osConfig.mySystem.theme.colors;
  hex = lib.removePrefix "#";
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.sleek;
    colorScheme = "custom";
    customColorScheme = {
      text = hex colors.text;
      subtext = hex colors.muted;
      nav-active-text = hex colors.background;
      main = hex colors.background;
      main-elevated = hex colors.surfaceAlt;
      main-secondary = hex colors.surface;
      highlight = hex colors.surfaceAlt;
      highlight-elevated = hex colors.border;
      sidebar = hex colors.background;
      player = hex colors.surface;
      card = hex colors.surfaceAlt;
      shadow = "000000";
      selected-row = hex colors.surfaceAlt;
      button = hex colors.accent;
      button-secondary = hex colors.accent2;
      button-active = hex colors.accent2;
      button-disabled = hex colors.border;
      nav-active = hex colors.accent;
      play-button = hex colors.accent;
      playback-bar = hex colors.accent;
      tab-active = hex colors.surfaceAlt;
      notification = hex colors.surfaceAlt;
      notification-error = "ff5449";
      misc = hex colors.border;
    };
  };
}
