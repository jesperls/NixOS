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

      snis = "nh os switch $FLAKE --max-jobs 16";
      snub = "nh os boot $FLAKE --max-jobs 16";
      snus = "nh os switch $FLAKE --update --max-jobs 16";
      snuf = "nh clean all --keep 5";
      nfu = "cd $FLAKE && nix flake update";

      cat = "bat --paging=never";
      trash = "trash-put";
      del = "trash-put";

      yt-dlp = "noglob yt-dlp";
      ytmp3 = "noglob yt-dlp -x --audio-format mp3 --no-playlist --downloader aria2c --downloader-args aria2c:'-x 16 -s 16 -k 1M'";
      ytmp4 = "noglob yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' --no-playlist --downloader aria2c --downloader-args aria2c:'-x 16 -s 16 -k 1M'";
      ytbest = "noglob yt-dlp -f 'bestvideo+bestaudio' --merge-output-format mkv --no-playlist --downloader aria2c --downloader-args aria2c:'-x 16 -s 16 -k 1M'";

      oracle = "ssh oracle";
      nuwa = "ssh -t nuwa";

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

      # snil <input>... — rebuild with inputs overridden to local checkouts
      snil() {
        if [ "$#" -eq 0 ]; then
          echo "usage: snil <input>... (ambxst, qs-vpets, quickshell-package-manager)" >&2
          return 1
        fi
        local -a overrides
        local input dir
        for input in "$@"; do
          case "$input" in
            quickshell-package-manager|qpm) input=quickshell-package-manager dir=nix-quickshell-package-manager ;;
            ambxst) dir=Ambxst ;;
            *) dir=$input ;;
          esac
          overrides+=(--override-input "$input" "path:$FLAKE/$dir")
        done
        nh os switch "$FLAKE" -- --no-write-lock-file "''${overrides[@]}"
      }
    '';
  };
}
