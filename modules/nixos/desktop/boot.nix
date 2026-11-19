{
  config,
  lib,
  pkgs,
  ...
}:

let
  c = config.mySystem.theme.colors;
in
{
  boot.plymouth = {
    enable = true;
    theme = "blahaj";
    themePackages = [ pkgs.plymouth-blahaj-theme ];
  };

  console.colors = lib.mkDefault (
    map (lib.removePrefix "#") [
      c.background
      "#f38ba8"
      "#a6e3a1"
      "#f9e2af"
      c.accent
      "#cba6f7"
      c.accent
      c.muted
      c.border
      "#f38ba8"
      "#a6e3a1"
      "#f9e2af"
      c.accent2
      "#cba6f7"
      c.accent2
      c.text
    ]
  );
}
