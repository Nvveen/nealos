{ config, lib, ... }:
let
  avatar = ../../users + "/${config.home.username}/files/avatar.png";
in
{
  imports = [
    ./hypr
    ./noctalia
    ./theming
    ./starship.nix
    ./bitwarden.nix
  ];

  home.file.".face.icon" = lib.mkIf (builtins.pathExists avatar) { source = avatar; };
}
