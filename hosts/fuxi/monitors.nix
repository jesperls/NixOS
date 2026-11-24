{ ... }:

{
  mySystem.monitors = [
    {
      name = "eDP-1";
      resolution = "2944x1840";
      refreshRate = 90;
      position = "0x0";
      scale = 1.6; # 2944x1840 / 1.6 = exact 1840x1150 logical pixels
    }
  ];
}
