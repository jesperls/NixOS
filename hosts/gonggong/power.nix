{ config, pkgs, ... }:

{
  powerManagement.cpuFreqGovernor = "powersave";

  boot = {
    kernelParams = [
      "pcie_aspm.policy=powersupersave"
      "nmi_watchdog=0"
      "consoleblank=60"
    ];

    blacklistedKernelModules = [
      "bluetooth"
      "btusb"
      "btrtl"
      "btintel"
      "btmtk"
      "btbcm"
      "snd_hda_intel"
    ];

    extraModprobeConfig = ''
      options iwlwifi bt_coex_active=0
    '';

    kernel.sysctl = {
      "kernel.nmi_watchdog" = 0;
      "vm.dirty_writeback_centisecs" = 1500;
      "vm.dirty_expire_centisecs" = 3000;
    };
  };

  systemd.tmpfiles.rules = [
    "w /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference - - - - balance_power"
  ];

  services.udev.extraRules = ''
    # Keep Intel AX210 Wi-Fi (8086:2725) low-latency while enabling runtime PM on other PCI devices (incl. unplugged igc).
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x2725", GOTO="gonggong_pci_pm_end"
    ACTION=="add", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="auto"
    LABEL="gonggong_pci_pm_end"

    # Suspend onboard ASUS AURA LED (0b05:18f3) and blacklisted AX210 BT (8087:0032) so xHCI can suspend.
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0b05", ATTR{idProduct}=="18f3", TEST=="power/control", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="8087", ATTR{idProduct}=="0032", TEST=="power/control", ATTR{power/control}="auto"

    # Keep SATA ALPM at med_power_with_dipm (safe for Samsung 850 EVO).
    ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", TEST=="link_power_management_policy", ATTR{link_power_management_policy}="med_power_with_dipm"
  '';

  services.fwupd.enable = false;
  services.thermald.enable = true;

  environment.systemPackages = with pkgs; [
    ethtool
    pciutils
    powertop
    usbutils
    config.boot.kernelPackages.turbostat
  ];
}
