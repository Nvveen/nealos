{ ... }:

{
  users.users."neal" = {
    initialPassword = "changeme"; # Change this to use sops
    isNormalUser = true;
    description = "Neal van Veen";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    # packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGC8kNuZ6WSdY6yo6SYE/jdKrXUiG/X/14tfs26OGkbq" ];
  };

  home-manager.users."neal" = import ./home.nix;
}
