{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    liquidctl
    lm_sensors
    nvtopPackages.full
  ];

  services.udev.extraRules = ''
    # NZXT Kraken coolers
    SUBSYSTEM=="usb", ATTR{idVendor}=="1e71", MODE="0666"
    # NZXT Smart Device / Grid
    SUBSYSTEM=="usb", ATTR{idVendor}=="1e71", ATTR{idProduct}=="2006", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1e71", ATTR{idProduct}=="2007", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1e71", ATTR{idProduct}=="2009", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1e71", ATTR{idProduct}=="200d", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1e71", ATTR{idProduct}=="200e", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1e71", ATTR{idProduct}=="200f", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1e71", ATTR{idProduct}=="2010", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1e71", ATTR{idProduct}=="2011", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1e71", ATTR{idProduct}=="2012", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1e71", ATTR{idProduct}=="2014", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1e71", ATTR{idProduct}=="2019", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1e71", ATTR{idProduct}=="201a", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1e71", ATTR{idProduct}=="3008", MODE="0666"
  '';

  boot.kernelModules = [
    "coretemp"
    "nct6775"
  ];

  systemd.services.nzxt-fan-curve = {
    description = "Set NZXT AIO fan curve";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "nzxt-fan-curve" ''
        # Initialize all NZXT devices
        ${pkgs.liquidctl}/bin/liquidctl initialize all 2>/dev/null || true

        # Set a quiet fan curve for the AIO pump and fans
        # Format: (temp_celsius, duty_percent)
        # This curve keeps fans quiet at low temps and ramps up gradually
        ${pkgs.liquidctl}/bin/liquidctl --match kraken set fan speed 20 25 30 30 40 40 50 60 60 80 70 100 2>/dev/null || true
        ${pkgs.liquidctl}/bin/liquidctl --match kraken set pump speed 20 50 30 50 40 60 50 70 60 85 70 100 2>/dev/null || true

        echo "NZXT fan curve applied"
      '';
    };
  };
}
