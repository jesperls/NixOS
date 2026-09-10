{
  config,
  lib,
  ...
}:

let
  cfg = config.mySystem.performance;
in
{
  hardware.enableRedistributableFirmware = true;

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = config.mySystem.system.keepGenerations;
        editor = false;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };

    tmp.useTmpfs = true;
    tmp.tmpfsSize = "75%";

    kernelParams = [
      "quiet"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ]
    ++ lib.optional (cfg.cpuVendor == "amd") "amd_pstate=active"
    ++ lib.optional (
      cfg.transparentHugepages != null
    ) "transparent_hugepage=${cfg.transparentHugepages}";

    consoleLogLevel = 0;
    initrd.verbose = false;
  };
}
