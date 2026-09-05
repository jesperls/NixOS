{
  pkgs,
  ...
}:

{
  programs.firefox = {
    enable = true;

    configPath = ".mozilla/firefox";

    nativeMessagingHosts = [ pkgs.fx-cast-bridge ];

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;

      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
    };

    profiles.default = {
      id = 0;
      name = "default";
      path = "main";
      isDefault = true;

      settings = {
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;

        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "widget.use-xdg-desktop-portal.mime-handler" = 0;

        "browser.download.always_ask_before_handling_new_types" = true;
        "browser.download.start_downloads_in_tmp_dir" = true;

        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "browser.send_pings" = false;

        "browser.shell.checkDefaultBrowser" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "extensions.pocket.enabled" = false;

        "general.smoothScroll" = true;

        "browser.sessionstore.resume_from_crash" = false;
      };
    };
  };
}
