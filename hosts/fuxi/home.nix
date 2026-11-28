{ ... }:

{
  imports = [
    ../../modules/home-manager/bundle.nix
    ../../modules/home-manager/desktop/bundle.nix

    ../../modules/home-manager/programs/firefox.nix
    ../../modules/home-manager/programs/vesktop.nix

    ./packages.nix
  ];

  home.stateVersion = "26.05";

  programs.pangu.hyprland.preset.settings = {
    gestures = {
      workspace_swipe = true;
      overview_swipe = true;
      scratchpad_swipe = true;
    };
    apps.shortcuts = [
      {
        key = "D";
        command = "vesktop";
        description = "Apps: Vesktop";
      }
    ];
  };

  programs.zsh.shellAliases = {
    trash = "trash-put";
    del = "trash-put";
    yt-dlp = "noglob yt-dlp";
  };
}
