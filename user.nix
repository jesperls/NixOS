{
  hostname = "nixos";
  
  username = "jesperls";
  fullName = "Jesper Lönn Stråle";
  
  timeZone = "Europe/Stockholm";
  locale = "en_US.UTF-8";
  keyboardLayout = "se";
  consoleKeyMap = "sv-latin1";
  
  extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };
}