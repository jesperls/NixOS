{
  config,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./power.nix

    ../../modules/nixos/bundle.nix

    ../../modules/nixos/services/docker.nix
    ../../modules/nixos/services/pufferpanel-lazymc.nix
  ];

  mySystem = {
    system = {
      hostName = "gonggong";
      regionalLocale = "sv_SE.UTF-8";
      passwordlessSudo = true;
    };

    network.allowedTCPPorts = [
      80
      443
      8080
      5657
      25565
    ];
    network.allowedUDPPorts = [
      24454
    ];

    performance.cpuVendor = "intel";

    services.pufferpanelLazymc = {
      serverId = "36324fc3";
      serverDirectory = "/var/lib/pufferpanel/servers/36324fc3";
      mcVersion = "1.21.1";
      protocol = 767;
      sleepAfter = 1800;
      holdTimeout = 15;
      motd = {
        sleeping = "§5§kaaa§r §nAll the Mods X Aeronautics§r §5§kaaa§r\n§7Sleeping — §aJoin to wake (~1 min)";
        starting = "§5§kaaa§r §nAll the Mods X Aeronautics§r §5§kaaa§r\n§eWaking up... please wait (~1 min)";
        stopping = "§5§kaaa§r §nAll the Mods X Aeronautics§r §5§kaaa§r\n§7Entering standby...";
      };
      kickMessage = {
        starting = "§6ATM 10 Aeronautics is waking up!§r\n\n§7Cold start takes about 60 seconds.\nPlease reconnect in a moment.";
        stopping = "§7ATM 10 Aeronautics is entering standby.§r\n\nPlease reconnect in a moment to wake it again.";
      };
    };
  };

  networking.interfaces.enp2s0.wakeOnLan = {
    enable = true;
    policy = [ "magic" ];
  };

  services.openssh.enable = true;
  security.acme = {
    acceptTerms = true;
    defaults.email = config.mySystem.user.email;
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    clientMaxBodySize = "100m"; # Panel file uploads exceed nginx's 1m default.

    virtualHosts."bonecontrol.com" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://127.0.0.1:8080";
      locations."/".proxyWebsockets = true;
    };
  };

  users.users.${config.mySystem.user.username}.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxukHRKsCPDFufjQWysjpTyJF9LfJMMG4+SHvB16z9sOGi9LH8+6Og/vOT0vQ8qZ20EsHDVMnEt8QsDkP20W2MHuIE3Batrq2Pr08L7HpjUbCI8IPQ2oB0fhynG336bEMLpFXx+0NiHey8C8qbaPu9PvC++9qPlbiY5PhVF+lIB0JkL5FhSFNQ+Q1Z3k96fxxb8A0AnF4CA6d2F6h2yWulroNaPrKj1Lp+ElH6oOcjjY1UL/d3MYnl0OdF6Sc9/VIMEDcX9HA5UHX7l32VO8s1in5Q9x6LJdqIiWnHmU9TbOH4UZ4T/5fTME2t68SlfPmckFpinNPUEgmrQVT411ez ssh-key-2024-09-29"
  ];

  home-manager.users.${config.mySystem.user.username}.imports = [ ./home.nix ];

  system.stateVersion = "26.05";
}
