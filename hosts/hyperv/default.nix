{
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix
    ../../modules/base
    ../../modules/desktop/nixos
    ../../modules/profiles/development/nixos
  ];
}
