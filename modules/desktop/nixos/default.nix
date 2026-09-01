{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./sddm.nix
    ./plymouth
  ];

  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;

  services.upower.enable = lib.mkDefault true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  boot.kernelParams = [
    "quiet"
    "systemd.show_status=false"
    "rd.systemd.show_status=false"
  ];
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.hyprland = {
      default = [
        "hyprland"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
    };
  };

  environment.systemPackages = [
    pkgs.ddcutil
    pkgs.foot
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.hyprpolkitagent
    pkgs.pywalfox-native
    # File manager and related packages
    pkgs.nautilus
    pkgs.libheif
    pkgs.libheif.out
  ];

  # Only helps locally rendered terminals; SSH/VS Code clients need the font installed themselves.
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  home-manager.sharedModules = [
    inputs.noctalia.homeModules.default
    ../home
  ];

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  programs.firefox = {
    enable = true;
    policies.ExtensionSettings = {
      "pywalfox@frewacom.org" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/pywalfox/latest.xpi";
      };
      "uBlock0@raymondhill.net" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        installation_mode = "force_installed";
        default_area = "menupanel";
        private_browsing = true;
      };
    };
  };

  systemd.user.services.hyprpolkitagent = {
    description = "Hyprland polkit authentication agent";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
    };
  };

  programs.dconf.enable = true;

  # for file managers
  services.gvfs.enable = true;

  # noctalia's papirus-icons template guards on /usr/share/icons before it will
  # do anything, and that path doesn't exist on NixOS. Provide it so the script
  # can find the theme and copy it somewhere writable.
  systemd.tmpfiles.rules = [
    "d /usr/share/icons 0755 root root -"
    "L+ /usr/share/icons/Papirus-Dark - - - - ${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark"
    "L+ /usr/share/icons/Papirus - - - - ${pkgs.papirus-icon-theme}/share/icons/Papirus"
  ];

  environment.pathsToLink = [ "share/thumbnailers" ];
}
