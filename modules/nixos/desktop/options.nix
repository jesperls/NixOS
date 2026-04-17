{ lib, ... }:

{
  options.mySystem.desktop = {
    lockscreen = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the desktop lockscreen.";
      };
      lockOnSleep = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Lock the screen before the system goes to sleep.";
      };
      lockOnBoot = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Lock the screen automatically when the session starts.";
      };
    };
  };
}
