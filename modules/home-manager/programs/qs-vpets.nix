{ inputs, ... }:

{
  imports = [ inputs.qs-vpets.homeManagerModules.default ];

  programs.qs-vpets.enable = true;
}
