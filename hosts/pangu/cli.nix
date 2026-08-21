{ osConfig, ... }:

{
  programs.ssh.settings = {
    oracle = {
      HostName = osConfig.mySystem.network.hosts.oracle;
      User = "ubuntu";
      SetEnv.TERM = "xterm-256color";
    };

    nuwa = {
      HostName = osConfig.mySystem.network.hosts.nuwa;
      User = "jesper";
      SetEnv.TERM = "xterm-256color";
    };

    gonggong = {
      HostName = osConfig.mySystem.network.hosts.gonggong;
      User = "jesperls";
      SetEnv.TERM = "xterm-256color";
    };
  };

  programs.zsh.shellAliases = {
    oracle = "ssh oracle";
    nuwa = "ssh -t nuwa";
    gonggong = "ssh -t gonggong";

    webcam = "scrcpy --video-source=camera --camera-facing=back --camera-size=1920x1080 --v4l2-sink=/dev/video${toString osConfig.mySystem.hardware.webcam.videoNr} --no-audio --no-playback";
    phone = "scrcpy --render-driver=vulkan";
  };
}
