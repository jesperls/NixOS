{ config, osConfig, ... }:

{
  imports = [
    ../../modules/home-manager/bundle.nix
    ../../modules/home-manager/desktop/bundle.nix

    ../../modules/home-manager/programs/firefox.nix
    ../../modules/home-manager/programs/nixcord.nix
    ../../modules/home-manager/programs/obs.nix
    ../../modules/home-manager/programs/spicetify.nix
    ../../modules/home-manager/programs/flatpak.nix
    ../../modules/home-manager/services/deltatune.nix
    ../../modules/home-manager/services/foxy.nix

    ./packages.nix
  ];

  services.easyeffects.enable = true;

  home.stateVersion = "26.05";

  programs.pangu.hyprland.preset.settings.apps.shortcuts = [
    {
      key = "R";
      command = "ratty";
      description = "Apps: ratty";
    }
    {
      key = "D";
      command = "discord";
      description = "Apps: Discord";
    }
    {
      key = "M";
      command = "easyeffects";
      description = "Apps: EasyEffects";
    }
  ];

  programs.zsh.shellAliases = {
    trash = "trash-put";
    del = "trash-put";
    yt-dlp = "noglob yt-dlp";
    ytmp3 = "noglob yt-dlp -x --audio-format mp3 --no-playlist --downloader aria2c --downloader-args aria2c:'-x 16 -s 16 -k 1M'";
    ytmp4 = "noglob yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' --no-playlist --downloader aria2c --downloader-args aria2c:'-x 16 -s 16 -k 1M'";
    ytbest = "noglob yt-dlp -f 'bestvideo+bestaudio' --merge-output-format mkv --no-playlist --downloader aria2c --downloader-args aria2c:'-x 16 -s 16 -k 1M'";
    deltamod = ''protontricks -c 'wine "${config.home.homeDirectory}/.steam/steam/steamapps/compatdata/1671210/pfx/drive_c/Program Files/Deltamod/Deltamod.exe" --disable-gpu --no-sandbox' 1671210'';
    webcam = "scrcpy --video-source=camera --camera-facing=back --camera-size=1920x1080 --v4l2-sink=/dev/video${toString osConfig.mySystem.hardware.webcam.videoNr} --no-audio --no-playback";
    phone = "scrcpy --render-driver=vulkan";
  };
}
