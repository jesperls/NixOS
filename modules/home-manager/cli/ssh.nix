{
  lib,
  osConfig,
  ...
}:

let
  hosts = osConfig.mySystem.network.hosts;
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        ServerAliveInterval = 30;
        ServerAliveCountMax = 3;
      };
    }
    // lib.mapAttrs (
      name: host:
      {
        HostName = host.address;
        SetEnv.TERM = "xterm-256color";
      }
      // lib.optionalAttrs (host.sshUser != null) { User = host.sshUser; }
    ) hosts;
  };

  programs.zsh.shellAliases = lib.mapAttrs' (
    name: host: lib.nameValuePair name ("ssh " + lib.optionalString host.sshTty "-t " + name)
  ) hosts;
}
