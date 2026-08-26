# Machine-specific settings for the `vmware` host. Shared settings live in ../../common.

{ ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nealxos";

  # Release this machine was first installed with; do not bump on upgrade.
  system.stateVersion = "26.05";
}
