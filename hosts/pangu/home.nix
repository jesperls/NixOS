{ osConfig, ... }:

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

  programs.zsh.shellAliases = {
    deltamod = ''protontricks -c 'wine "/home/jesperls/.steam/steam/steamapps/compatdata/1671210/pfx/drive_c/Program Files/Deltamod/Deltamod.exe" --disable-gpu --no-sandbox' 1671210'';
    webcam = "scrcpy --video-source=camera --camera-facing=back --camera-size=1920x1080 --v4l2-sink=/dev/video${toString osConfig.mySystem.hardware.webcam.videoNr} --no-audio --no-playback";
    phone = "scrcpy --render-driver=vulkan";
  };
}
