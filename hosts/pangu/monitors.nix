{ ... }:

{
  mySystem.monitors = [
    {
      name = "DP-3";
      resolution = "2560x1440";
      refreshRate = 240;
      position = "0x0";
      vrr = 1;
    }
    {
      name = "DP-2";
      resolution = "2560x1440";
      refreshRate = 144;
      position = "2560x0";
    }
    {
      name = "HDMI-A-1";
      resolution = "1920x1080";
      refreshRate = 60;
      position = "-1080x0";
      transform = 1;
    }
  ];
}
