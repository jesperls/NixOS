{
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.x1e-nixos-config.nixosModules.x1e

    ./hardware-configuration.nix
    ./monitors.nix

    ../../modules/nixos/bundle.nix
    ../../modules/nixos/desktop/bundle.nix

    ../../modules/nixos/programs/filemanager.nix
  ];

  hardware.lenovo-yoga-slim7x.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest; # Resolves duplicate mkDefault from core/boot.nix and x1e80100.nix.
  boot.loader = {
    timeout = 5;
    systemd-boot.editor = true;
  };

  mySystem = {
    system = {
      hostName = "fuxi";
      regionalLocale = "sv_SE.UTF-8";
      passwordlessSudo = true;
      keepGenerations = 2; # Windows SYSTEM_DRV EFI partition is small
    };

    network.hosts = {
      nuwa = {
        address = "192.168.1.49";
        sshUser = "jesper";
        sshTty = true;
      };
      oracle = {
        address = "132.145.48.11";
        sshUser = "ubuntu";
      };
      gonggong = {
        address = "192.168.50.96";
        sshUser = "jesperls";
        sshTty = true;
      };
    };

    theme.preset = "deep-space";
    performance.transparentHugepages = "madvise";
    performance.zram.memoryPercent = 50;
  };

  services.openssh.enable = true;

  users.users.${config.mySystem.user.username}.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDzETJmYhmqxik4LDk6CdNOnVZ8cC+14bdzL1ouSjnJBSENcS9lwrS76cvOC21wOyWRZcwdDrK86IYr9phkR+z3UcFSu4sAJxkoz78CkCP/alQ+Gz0WFsgHhgpTKFNyPswwJu3aZcRTYJZnYndU3b2ttCD4elm0HA+lujQOMkh5/niMGOAIQq0MEC0EuxZzwBprn2xZk6olewHPBbUEr9fil2Yu65EAAyYTamNDcYJzwALKsTM1Gd4MekRCiPs7OEO4NKU4N8st2A0bMb151HRY4/lkIqNekJDAKGblKAzlZ8AuSgOnnfGvJbjmBLv519JI8lnZrKHBNpW4uuQmF0wb elonjes@elx-5cg2212nwm"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxukHRKsCPDFufjQWysjpTyJF9LfJMMG4+SHvB16z9sOGi9LH8+6Og/vOT0vQ8qZ20EsHDVMnEt8QsDkP20W2MHuIE3Batrq2Pr08L7HpjUbCI8IPQ2oB0fhynG336bEMLpFXx+0NiHey8C8qbaPu9PvC++9qPlbiY5PhVF+lIB0JkL5FhSFNQ+Q1Z3k96fxxb8A0AnF4CA6d2F6h2yWulroNaPrKj1Lp+ElH6oOcjjY1UL/d3MYnl0OdF6Sc9/VIMEDcX9HA5UHX7l32VO8s1in5Q9x6LJdqIiWnHmU9TbOH4UZ4T/5fTME2t68SlfPmckFpinNPUEgmrQVT411ez ssh-key-2024-09-29"
  ];

  home-manager.users.${config.mySystem.user.username}.imports = [ ./home.nix ];

  system.stateVersion = "26.05";
}
