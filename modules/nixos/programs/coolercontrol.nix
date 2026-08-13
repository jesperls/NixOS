{
  config,
  lib,
  ...
}:

{
  options.mySystem.programs.coolercontrol.enable = lib.mkEnableOption "CoolerControl GUI & daemon";

  config = lib.mkIf config.mySystem.programs.coolercontrol.enable {
    programs.coolercontrol.enable = true;
  };
}
