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

      snis = "nh os switch $FLAKE";
      snub = "nh os boot $FLAKE";
      snus = "nh os switch $FLAKE --update";
      snuf = "nh clean all --keep 5";
      nfu = "cd $FLAKE && nix flake update";

      cat = "bat --paging=never";
      trash = "trash-put";
      del = "trash-put";

      yt-dlp = "noglob yt-dlp";
      ytmp3 = "noglob yt-dlp -x --audio-format mp3 --no-playlist --downloader aria2c --downloader-args aria2c:'-x 16 -s 16 -k 1M'";
      ytmp4 = "noglob yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' --no-playlist --downloader aria2c --downloader-args aria2c:'-x 16 -s 16 -k 1M'";
      ytbest = "noglob yt-dlp -f 'bestvideo+bestaudio' --merge-output-format mkv --no-playlist --downloader aria2c --downloader-args aria2c:'-x 16 -s 16 -k 1M'";

      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph";
      gd = "git diff";
    };

    loginExtra = ''
      if [ "$(tty)" = /dev/tty1 ] && [ -z "$WAYLAND_DISPLAY" ]; then
        exec start-hyprland
      fi
    '';

    initContent = ''
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' menu select
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

      autoload -z edit-command-line
      zle -N edit-command-line
      bindkey "^X^E" edit-command-line
    '';
  };
}
