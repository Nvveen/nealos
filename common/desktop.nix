{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./theming/sddm.nix
  ];

  boot.plymouth = {
    enable = true;
    theme = "rings";
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ "rings" ]; })
    ];
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

  environment.systemPackages = [
    pkgs.foot
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  home-manager.sharedModules = [
    inputs.noctalia.homeModules.default
    ./theming
  ];

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  programs.firefox = {
    enable = true;
    policies.extensionSettings = {
      "pywalfox@frewacom.org" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/pywalfox/latest.xpi";
      };
    };
  };
}
