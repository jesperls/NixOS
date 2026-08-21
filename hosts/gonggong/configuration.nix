{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos/bundle.nix
  ];

  mySystem = {
    user = {
      username = "jesperls";
      fullName = "Jesper Lönn Stråle";
      email = "jesper.ls@hotmail.com";
    };

    system = {
      hostName = "gonggong";
      regionalLocale = "sv_SE.UTF-8";
    };

    performance.cpuVendor = "intel";

    services.docker.enable = true;
  };

  # boot.nix defaults to the CachyOS kernel; servers take the vanilla one
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.interfaces.enp2s0.wakeOnLan = {
    enable = true;
    policy = [ "magic" ];
  };

  users.users.${config.mySystem.user.username}.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxukHRKsCPDFufjQWysjpTyJF9LfJMMG4+SHvB16z9sOGi9LH8+6Og/vOT0vQ8qZ20EsHDVMnEt8QsDkP20W2MHuIE3Batrq2Pr08L7HpjUbCI8IPQ2oB0fhynG336bEMLpFXx+0NiHey8C8qbaPu9PvC++9qPlbiY5PhVF+lIB0JkL5FhSFNQ+Q1Z3k96fxxb8A0AnF4CA6d2F6h2yWulroNaPrKj1Lp+ElH6oOcjjY1UL/d3MYnl0OdF6Sc9/VIMEDcX9HA5UHX7l32VO8s1in5Q9x6LJdqIiWnHmU9TbOH4UZ4T/5fTME2t68SlfPmckFpinNPUEgmrQVT411ez ssh-key-2024-09-29"
  ];

  home-manager.users.${config.mySystem.user.username}.imports = [ ./home.nix ];

  system.stateVersion = config.mySystem.system.stateVersion;
}
