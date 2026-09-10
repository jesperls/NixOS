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

      "credential \"https://github.com\"" = {
        helper = [
          ""
          "!gh auth git-credential"
        ];
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
