{ config, lib, osConfig, ... }:

{
  imports = [ ./user.nix ./dotfiles ];

  # Symlinked here rather than placed by sops so the key stays on tmpfs and the
  # parent directories end up owned by neal.
  xdg.configFile."sops/age/keys.txt" = lib.mkIf osConfig.nealos.users.neal.secrets.enable {
    source = config.lib.file.mkOutOfStoreSymlink "/run/secrets/sops_init/age/keys_txt";
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."github.com" = lib.mkIf osConfig.nealos.users.neal.secrets.enable {
      IdentityFile = "/run/secrets/users/neal/id_ed25519";
      IdentitiesOnly = true;
    };
  };
}
