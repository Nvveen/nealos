{
  inputs,
  pkgs,
  ...
}:

{
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

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "nordic";
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
}
