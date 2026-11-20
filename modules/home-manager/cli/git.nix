{
  osConfig,
  ...
}:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = osConfig.mySystem.user.fullName;
        email = osConfig.mySystem.user.email;
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      fetch.prune = true;
      merge.conflictstyle = "zdiff3";
      rerere.enabled = true;
      diff.colorMoved = "default";
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
    };
  };
}
