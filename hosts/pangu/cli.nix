{ osConfig, ... }:

{
  programs.ssh.settings = {
    oracle = {
      HostName = "132.145.48.11";
      User = "ubuntu";
      IdentityFile = "~/.ssh/id_rsa";
      SetEnv.TERM = "xterm-256color";
    };

    nuwa = {
      HostName = "192.168.1.49";
      User = "jesper";
      SetEnv.TERM = "xterm-256color";
    };
  };

  programs.zsh.shellAliases = {
    oracle = "ssh oracle";
    nuwa = "ssh -t nuwa";

    webcam = "scrcpy --video-source=camera --camera-facing=back --camera-size=1920x1080 --v4l2-sink=/dev/video${toString osConfig.mySystem.hardware.webcam.videoNr} --no-audio --no-playback";
    phone = "scrcpy --render-driver=vulkan";
  };
}
