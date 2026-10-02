{ lib, pkgs, inputs, ... }:
{
  imports = [ ../../modules/profiles/development/home ];

  home.packages = (import ../../modules/common { inherit lib pkgs inputs; }).environment.systemPackages ++ [ pkgs.nh ];
  nix.package = pkgs.nix;
  nix.settings = (import ../../modules/common/nix-settings.nix { }).nix.settings;
  systemd.user.enable = false;
}