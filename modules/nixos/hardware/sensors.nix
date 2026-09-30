{
  pkgs,
  ...
}:

{
  hardware.i2c.enable = true; # ddcutil needs access to the monitor's I2C bus.

  environment.systemPackages = with pkgs; [
    lm_sensors
    nvtopPackages.full
  ];
}
