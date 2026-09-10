{
  config,
  pkgs,
  osConfig,
  ...
}:

{
  home.sessionVariables = {
    UV_PYTHON_PREFERENCE = "managed";

    FLAKE = osConfig.mySystem.paths.repoRoot;
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];

  xdg.systemDirs.data = [
    "${config.home.homeDirectory}/.local/share"
    "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
  ];
}
