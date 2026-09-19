{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
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
    tpm = true;
    espSize = "2G";
    passwordFile = "/tmp/disko-password";
  };

  boot.initrd = {
    systemd = {
      enable = true;
      network = {
        enable = true;
        networks."10-wired" = {
          matchConfig.Name = [
            "en*"
            "eth*"
          ];
          networkConfig.DHCP = "ipv4";
        };
        wait-online = {
          enable = true;
          anyInterface = true;
          timeout = 20;
        };
      };
    };

    clevisLuksAskpass = {
      enable = true;
      useTang = true;
    };
  };

  boot.loader.systemd-boot.enable = lib.mkForce false; # initial pre-enroll ba7l3qroot step
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    configurationLimit = 5;
  };

  boot.loader.timeout = 0;

  environment.systemPackages = [
    pkgs.clevis
    pkgs.sbctl
  ];

  home-manager.sharedModules = [ ./hypr/hyprland.nix ];
}
