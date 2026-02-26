{ pkgs, ... }:

{
  systemd.user.services.bonecontrol-listener = {
    Unit = {
      Description = "BoneControl socket listener";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.python3}/bin/python ${./scripts/bonecontrol-listener.py}";
      Restart = "on-failure";
      RestartSec = 2;
      Environment = [
        "BONECONTROL_LISTEN_HOST=0.0.0.0"
        "BONECONTROL_PORT=12345"
      ];
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
