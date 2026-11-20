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

    historySubstringSearch = {
      enable = true;
      searchUpKey = [
        "^[[A"
        "^[OA"
      ];
      searchDownKey = [
        "^[[B"
        "^[OB"
      ];
    };

    shellAliases = {
      ll = "eza -lha --sort=name";
      l = "eza -lh --sort=name";
      ls = "eza";
      la = "eza -la";
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
      setopt INTERACTIVE_COMMENTS

      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' menu select
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

      autoload -z edit-command-line
      zle -N edit-command-line
      bindkey "^X^E" edit-command-line

      bindkey "^[[H" beginning-of-line
      bindkey "^[OH" beginning-of-line
      bindkey "^[[F" end-of-line
      bindkey "^[OF" end-of-line
      bindkey "^[[3~" delete-char
      bindkey "^[[1;5D" backward-word
      bindkey "^[[1;5C" forward-word
      bindkey "^[[Z" reverse-menu-complete
    '';
  };
}
