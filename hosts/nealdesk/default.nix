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

  boot.initrd.systemd.enable = true;

  boot.initrd.availableKernelModules = [ "r8169" ];

  boot.initrd.network.enable = true;
  boot.initrd.systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "en*";
      networkConfig.DHCP = "yes";
      dhcpV4Config.ClientIdentifier = "mac";
    };
  };

  boot.initrd.network.ssh = {
    enable = true;
    port = 2222;
    hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    authorizedKeys = [
      ''command="systemctl default" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDFuFQCFGyUL3NY2xdTU6V7TQ5GN1IGL8UTxmS0X9Sq0 neal@nealmsi''
      ''restrict,pty,command="systemctl default" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHTXW4wVy7AIK2FA36K+OuKKmv5mMf/ef90gJqyE0DHk phone-nealdesk-unlock''
    ];
  };

  boot.loader.systemd-boot.enable = lib.mkForce false; # initial pre-enroll ba7l3qroot step
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    configurationLimit = 5;
  };

  boot.loader.timeout = 0;

  environment.systemPackages = [ pkgs.sbctl ];

  home-manager.sharedModules = [ ./hypr/hyprland.nix ];
}
