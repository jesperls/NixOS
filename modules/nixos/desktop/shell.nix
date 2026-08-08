{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.mySystem.desktop.shell.enable {
  programs.gpu-screen-recorder.enable = true;

  services.power-profiles-daemon.enable = true;

  fonts.packages = with pkgs; [
    ttf-phosphor-icons
    roboto
    roboto-mono
    terminus_font_ttf
    nerd-fonts.symbols-only
    (nerd-fonts.iosevka.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        find $out -name '*.ttf' ! -name 'IosevkaNerdFontMono-*' -delete
      '';
    }))
  ];
}
