# Standalone home-manager on a non-NixOS system (the devcontainer): provides what
# NixOS gives real hosts at the system level.
{ pkgs, ... }:
{
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true; # the home-manager CLI, for later switches
  home.packages = import ../packages.nix pkgs;
}