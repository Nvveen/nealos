{ pkgs, ... }:

{
  home.username = "neal";
  home.homeDirectory = "/home/neal";

  home.packages = with pkgs; [ ];

  programs.home-manager.enable = true;

  # Keep in sync with the initial home-manager release used for this user.
  home.stateVersion = "26.05";
}
