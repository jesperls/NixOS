{ inputs, pkgs, ... }:

let
  sunshinePkgs = import inputs.nixpkgs-sunshine {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in

{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    package = sunshinePkgs.sunshine.override {
      cudaSupport = true;
      cudaPackages = sunshinePkgs.cudaPackages;
    };
  };

  systemd.user.services.sunshine.environment = {
    LD_LIBRARY_PATH = "/run/opengl-driver/lib";
  };
}
