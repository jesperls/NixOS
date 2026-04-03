{
  inputs,
  pkgs,
  ...
}:
{
  home.packages = [ inputs.myna.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
