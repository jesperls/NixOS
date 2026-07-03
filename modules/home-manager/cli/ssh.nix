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

      oracle = {
        HostName = "132.145.48.11";
        User = "ubuntu";
        IdentityFile = "~/.ssh/id_rsa";
        # Remote hosts don't know kitty's terminfo.
        SetEnv.TERM = "xterm-256color";
      };

      nuwa = {
        HostName = "192.168.1.49";
        User = "jesper";
        SetEnv.TERM = "xterm-256color";
      };
    };
  };
}
