{ config, lib, inputs, ... }:

{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  options.nealos.users.neal.secrets.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Provision Neal's password, SSH identity and age key from SOPS.";
  };

  config = {
    users.users."neal" = {
      hashedPasswordFile = lib.mkIf config.nealos.users.neal.secrets.enable config.sops.secrets."users/neal/password".path;
      isNormalUser = true;
      description = "Neal van Veen";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      # packages = with pkgs; [ ];
    };

    sops.secrets = lib.mkIf config.nealos.users.neal.secrets.enable {
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
  };
}
