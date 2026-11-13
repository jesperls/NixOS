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
      merge.conflictstyle = "diff3";
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
  };
}
