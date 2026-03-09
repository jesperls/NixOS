{
  inputs,
  osConfig,
  ...
}:
{
  imports = [ inputs.quickshell-package-manager.homeManagerModules.default ];

  programs.quickshellPackageManager = {
    enable = true;
    packagesFile = osConfig.mySystem.paths.packagesFile;
    channel = "nixos-unstable";
    rebuildAlias = "nh os switch ${osConfig.mySystem.paths.repoRoot}";
    baseColors = osConfig.mySystem.theme.colors // {
      scrollbar = osConfig.mySystem.theme.colors.muted;
      button = osConfig.mySystem.theme.colors.accent;
      buttonDisabled = osConfig.mySystem.theme.colors.surfaceAlt;
    };
    baseRounding = osConfig.mySystem.theme.rounding;
  };
}
