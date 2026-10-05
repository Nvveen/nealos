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
  };

  sops.secrets = {
    "users/neal/password" = {
      sopsFile = ./secrets/keys.yaml;
      neededForUsers = true;
    };
    "users/neal/id_ed25519" = {
      sopsFile = ./secrets/keys.yaml;
      owner = "neal";
      mode = "0600";
    };
    "sops_init/age/keys_txt" = {
      owner = "neal";
      mode = "0600";
    };
  };

  home-manager.users."neal" = import ./home.nix;
}
