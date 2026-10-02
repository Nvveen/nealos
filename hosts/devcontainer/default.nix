{ pkgs, ... }:
{
  imports = [ ../../modules/profiles/development/home ];

  home.packages = [ pkgs.nh ];
  nix.package = pkgs.nix;
  nix.settings = (import ../../modules/common/nix-settings.nix { }).nix.settings;
  systemd.user.enable = false;
}