# Machine-specific settings for the `vmware` host. Shared settings live in ../../common.

{ pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.kernelModules = [ "hyperv_drm" ];

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

  networking.hostName = "nealxos";

  # Release this machine was first installed with; do not bump on upgrade.
  system.stateVersion = "26.05";

  home-manager.sharedModules = [ ./hypr/hyprland.nix ];
}
