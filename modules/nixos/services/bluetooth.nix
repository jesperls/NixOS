{ ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        KernelExperimental = true; # Enables ISO sockets required by LE Audio BAP.
        FastConnectable = true;
      };
    };
  };
}
