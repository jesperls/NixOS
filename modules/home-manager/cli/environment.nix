{
  config,
  osConfig,
  ...
}:

{
  home.sessionVariables = {
    UV_PYTHON_PREFERENCE = "managed";

    NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.local";

    FLAKE = osConfig.mySystem.paths.repoRoot;
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];
}
