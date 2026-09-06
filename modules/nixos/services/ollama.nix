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
      package = lib.mkDefault (
        if config.mySystem.hardware.nvidia.enable then pkgs.ollama-cuda else pkgs.ollama-cpu
      );
    };
  };
}
