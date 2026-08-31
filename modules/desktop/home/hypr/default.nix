{ pkgs, ... }:
{
  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;

  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
  };
}
