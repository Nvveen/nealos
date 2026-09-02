# Machine-specific settings for the `hyperv` host. Shared settings live under ../../modules.

{ pkgs, ... }:

{
  boot.loader.limine.enable = true;
  # The 1G ESP fills up quickly once each generation ships a kernel and initrd.
  boot.loader.limine.maxGenerations = 20;
  boot.loader.efi.canTouchEfiVariables = true;

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
}
