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

  networking.hostName = "nealdesk";
  system.stateVersion = "26.05";

  nealos.disk = {
    device = "/dev/disk/by-id/nvme-eui.002538db11c3bf88";
    encrypt = true;
    hibernate = false;
    tpm = false;
    espSize = "2G";
    passwordFile = "/tmp/disko-password";
  };

  boot.initrd.systemd.enable = true;

  boot.loader.systemd-boot.enable = true; # initial pre-enroll boot step
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = [ pkgs.sbctl ];
}
