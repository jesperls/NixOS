{ osConfig, ... }:

{
  programs.zsh = {
    enable = true;
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
      ll = "eza -lha --group-directories-first --sort=name";
      l = "eza -lh --group-directories-first --sort=name";
      ls = "eza --group-directories-first";
      la = "eza -la --group-directories-first";
      lt = "eza --tree --level=2";

      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      snis = ''nh os switch "$FLAKE"'';
      snub = ''nh os boot "$FLAKE"'';
      snus = ''nh os switch "$FLAKE" --update'';
      snuf = "nh clean all --keep ${toString osConfig.mySystem.system.keepGenerations}";
      nfu = ''cd -- "$FLAKE" && nix flake update'';

      cat = "bat --paging=never";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph";
      gd = "git diff";
    };

    initContent = ''
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' menu select
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

      autoload -z edit-command-line
      zle -N edit-command-line
      bindkey "^X^E" edit-command-line

      [[ -n "''${terminfo[kcuu1]}" ]] && bindkey "''${terminfo[kcuu1]}" history-substring-search-up
      [[ -n "''${terminfo[kcud1]}" ]] && bindkey "''${terminfo[kcud1]}" history-substring-search-down
      bindkey "^[[A" history-substring-search-up
      bindkey "^[[B" history-substring-search-down
    '';
  };
}
