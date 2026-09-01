{ pkgs, lib, ... }:
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
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "adw-gtk3";
    icon-theme = "Papirus-Dark";
  };

  # noctalia's papirus template copies the theme into ~/.local/share/icons once
  # and never again, so a Papirus update in nixpkgs would never reach it. Clear
  # the copy on each rebuild; the next palette change re-copies from the store.
  home.activation.papirusRefresh = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run rm -rf "$HOME/.local/share/icons/Papirus" "$HOME/.local/share/icons/Papirus-Dark"
    run cp -r ${pkgs.papirus-icon-theme}/share/icons/Papirus "$HOME/.local/share/icons/"
    run cp -r ${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark "$HOME/.local/share/icons/"
    run chmod -R u+w "$HOME/.local/share/icons/Papirus" "$HOME/.local/share/icons/Papirus-Dark"
  '';
}
