{ inputs, ... }:

{
  imports = [ inputs.nixcord.homeModules.nixcord ];

  programs.nixcord = {
    enable = true;

    discord = {
      vencord.enable = true;
      openASAR.enable = true;
      krisp.enable = true;
    };
    config = {
      plugins = {
        alwaysTrust.enable = true;
        betterGifPicker.enable = true;
        biggerStreamPreview.enable = true;
        ClearURLs.enable = true;
        crashHandler.enable = true;
        fixYoutubeEmbeds.enable = true;
        gameActivityToggle.enable = true;
        imageZoom.enable = true;
        noTypingAnimation.enable = true;
        readAllNotificationsButton.enable = true;
        sendTimestamps.enable = true;
        volumeBooster.enable = true;
        youtubeAdblock.enable = true;
      };
    };
  };
}