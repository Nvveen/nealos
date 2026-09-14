{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/secrets
    ../../modules/disko
    ../../modules/desktop
    ../../modules/profiles/development/nixos
    ../../users/neal/nixos.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  nealos.disk = {
    device = "/dev/sda";
    encrypt = false;
  };

  boot.initrd.kernelModules = [ "hyperv_drm" ];

  services.tuned.enable = false;

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

  networking.hostName = "nealos-hyperv";

  # Release this machine was first installed with; do not bump on upgrade.
  system.stateVersion = "26.05";

  home-manager.sharedModules = [ ./hypr/hyprland.nix ];

  virtualisation.hypervGuest.enable = true;
}
