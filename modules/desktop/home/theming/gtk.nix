{ pkgs, ... }:
{
  home.packages = with pkgs; [
    adw-gtk3
    nwg-look
    glib
  ];
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3";
      package = pkgs.adw-gtk3;
    };
  };

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
}
