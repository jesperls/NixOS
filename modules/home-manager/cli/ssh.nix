{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        ServerAliveInterval = 30;
        ServerAliveCountMax = 3;
      };
    };
  };
}
