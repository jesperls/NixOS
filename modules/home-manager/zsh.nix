{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "eza -lha --icons --group-directories-first --sort=name";
      l = "eza -lh --icons --group-directories-first --sort=name";
      ls = "eza";
      ".." = "cd ..";
      snis = "nh os switch ~/nixos-config";
      snus = "nh os switch ~/nixos-config --update";
      snuf = "nh clean all --keep 5";
      disk = "ncdu";
      #cat = "bat";
      #grep = "rg";
      ytmp3 = "yt-dlp -x --audio-format mp3";
      ytmp4 =
        "yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best'";
    };

    initContent = ''
      # Fast directory navigation
      eval "$(zoxide init zsh)"

      # Auto-start Hyprland on tty1
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi
    '';
  };
}
