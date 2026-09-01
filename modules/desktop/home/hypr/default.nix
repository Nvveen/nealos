{ pkgs, ... }:
{
  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;
  xdg.configFile."hypr/programs.lua".source = ./programs.lua;
  xdg.configFile."hypr/bindings.lua".source = ./bindings.lua;

  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
  };
}
