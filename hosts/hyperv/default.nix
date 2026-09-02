{ inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    ./configuration.nix
    ../../modules/base
    ../../modules/disko
    ../../modules/desktop/nixos
    ../../modules/profiles/development/nixos
    ../../users/neal/nixos.nix
  ];
}
