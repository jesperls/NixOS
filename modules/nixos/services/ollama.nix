{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mySystem.services.ollama;
in
{
  options.mySystem.services.ollama.enable = lib.mkEnableOption "the Ollama LLM server";

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      environmentVariables = {
        OLLAMA_KEEP_ALIVE = "30m";
        OLLAMA_MAX_LOADED_MODELS = "2";
        OLLAMA_CONTEXT_LENGTH = "131072";
      };
    };

    users.users.ollama = {
      group = "ollama";
      extraGroups = [
        "video"
        "render"
      ];
      isSystemUser = true;
    };
    users.groups.ollama = { };
  };
}
