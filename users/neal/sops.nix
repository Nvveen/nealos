# Sops-backed parts of the user. Requires modules/secrets on the host.
{ config, ... }:

{
  users.users."neal".hashedPasswordFile = config.sops.secrets."users/neal/password".path;

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

  home-manager.users."neal" =
    { config, ... }:
    {
      # Symlinked here rather than placed by sops so the key stays on tmpfs and the
      # parent directories end up owned by neal.
      xdg.configFile."sops/age/keys.txt".source =
        config.lib.file.mkOutOfStoreSymlink "/run/secrets/sops_init/age/keys_txt";

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings."github.com" = {
          IdentityFile = "/run/secrets/users/neal/id_ed25519";
          IdentitiesOnly = true;
        };
      };
    };
}