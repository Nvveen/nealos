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
    openssh.authorizedKeys.keyFiles = [ /etc/ssh/ssh_host_ed25519_key.pub ];
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
