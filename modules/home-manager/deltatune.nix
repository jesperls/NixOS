{ inputs, ... }:

{
  imports = [ inputs.deltatune.homeManagerModules.default ];

  services.deltatune.enable = true;
}
