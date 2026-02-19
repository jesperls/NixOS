{ inputs, ... }:

{
  imports = [ inputs.myna.homeManagerModules.default ];

  programs.myna.enable = true;
}
