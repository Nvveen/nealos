{ config, ... }:

{
  users.users."neal" = {
    hashedPasswordFile = config.sops.secrets."users/neal/password".path;
    isNormalUser = true;
    description = "Neal van Veen";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    # packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGC8kNuZ6WSdY6yo6SYE/jdKrXUiG/X/14tfs26OGkbq"
    ];
  };

  sops.secrets = {
    "ssh/github" = {
      owner = "neal";
      mode = "0600";
    };
    "users/neal/password".neededForUsers = true;
    # No `path` into $HOME: sops runs as root and would create ~/.config as
    # root:root, locking home-manager out. home.nix symlinks it instead.
    "sops_init/age/keys_txt" = {
      owner = "neal";
      mode = "0600";
    };
  };

  home-manager.users."neal" = import ./home.nix;
}
