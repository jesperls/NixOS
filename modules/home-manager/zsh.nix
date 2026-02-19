{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
      expireDuplicatesFirst = true;
    };

    historySubstringSearch.enable = true;

    shellAliases = {
      ll = "eza -lha --icons --group-directories-first --sort=name";
      l = "eza -lh --icons --group-directories-first --sort=name";
      ls = "eza --icons --group-directories-first";
      la = "eza -la --icons --group-directories-first";
      lt = "eza --tree --level=2 --icons";

      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      snis = "nh os switch ~/nixos-config";
      snus = "nh os switch ~/nixos-config --update";
      snuf = "nh clean all --keep 5";
      nfu = "nix flake update";

      disk = "ncdu";
      cat = "bat --paging=never";
      #grep = "rg";
      rm = "trash-put";

      ytmp3 = "yt-dlp -x --audio-format mp3 --downloader aria2c --downloader-args aria2c:'-x 16 -s 16 -k 1M'";
      ytmp4 = "yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' --downloader aria2c --downloader-args aria2c:'-x 16 -s 16 -k 1M'";
      ytbest = "yt-dlp -f 'bestvideo+bestaudio' --merge-output-format mkv --downloader aria2c --downloader-args aria2c:'-x 16 -s 16 -k 1M'";

      oracle = "TERM=xterm-256color ssh -i ~/.ssh/id_rsa ubuntu@132.145.48.11";
      nuwa = "TERM=xterm-256color ssh -t jesper@192.168.1.49";

      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph";
      gd = "git diff";

      webcam = "scrcpy --video-source=camera --camera-facing=back --camera-size=1920x1080 --v4l2-sink=/dev/video2 --no-audio --no-playback";
      phone = "scrcpy --render-driver=vulkan";
    };

    initContent = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec start-hyprland
      fi

      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' menu select
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

      autoload -z edit-command-line
      zle -N edit-command-line
      bindkey "^X^E" edit-command-line
    '';
  };
}
