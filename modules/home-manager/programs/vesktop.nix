{ ... }:

{
  programs.vesktop = {
    enable = true;
    mutableSettings = true;

    settings = {
      appBadge = false;
      arRPC = true;
      checkUpdates = false;
      customTitleBar = false;
      discordBranch = "stable";
      hardwareAcceleration = true;
      hardwareVideoAcceleration = false; # nvidia-vaapi-driver stalls Chromium's VA-API video decoder.
      minimizeToTray = true;
      tray = true;
    };

    vencord = {
      mutableSettings = true;
      useSystem = true;
      settings = {
        autoUpdate = false;
        autoUpdateNotification = false;
        notifyAboutUpdates = false;
        enabledThemes = [ "pangu.css" ];
        plugins = {
          AlwaysTrust.enabled = true;
          BetterGifPicker.enabled = true;
          BiggerStreamPreview.enabled = true;
          ClearURLs.enabled = true;
          CrashHandler.enabled = true;
          FixYoutubeEmbeds.enabled = true;
          GameActivityToggle.enabled = true;
          ImageZoom.enabled = true;
          NoTypingAnimation.enabled = true;
          ReadAllNotificationsButton.enabled = true;
          SendTimestamps.enabled = true;
          WebKeybinds.enabled = true;
          WebScreenShareFixes.enabled = true;
          YoutubeAdblock.enabled = true;
        };
      };
    };
  };
}
