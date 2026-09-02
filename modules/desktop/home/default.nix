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

  xdg.mimeApps.defaultApplications = {
    "image/png" = "imv.desktop";
    "image/jpeg" = "imv.desktop";
    "image/gif" = "imv.desktop";
    "image/webp" = "imv.desktop";
    "image/tiff" = "imv.desktop";
    "image/bmp" = "imv.desktop";
    "image/svg+xml" = "imv.desktop";
  };
}
