# Machine-specific settings for the `hyperv` host. Shared settings live under ../../modules.

{ pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.kernelModules = [ "hyperv_drm" ];

  services.tuned.enable = false;

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

  networking.hostName = "nealos-hyperv";

  # Release this machine was first installed with; do not bump on upgrade.
  system.stateVersion = "26.05";

  home-manager.sharedModules = [ ./hypr/hyprland.nix ];
}
