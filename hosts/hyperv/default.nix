{ inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    ./hardware-configuration.nix
    ./configuration.nix
    ../../modules/common
    ../../modules/secrets
    ../../modules/disko
    ../../modules/desktop
    ../../modules/profiles/development/nixos
    ../../users/neal/nixos.nix
  ];
}
