{ config, ... }:

{
  home.username = "neal";
  home.homeDirectory = "/home/neal";

  imports = [ ../../dotfiles ];

  # Keep in sync with the initial home-manager release used for this user.
  home.stateVersion = "26.05";

  # Symlinked here rather than placed by sops so the key stays on tmpfs and the
  # parent directories end up owned by neal.
  xdg.configFile."sops/age/keys.txt".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/sops_init/age/keys_txt";

  programs.git = {
    settings.user = {
      name = "Neal van Veen";
      email = "nealvanveen@gmail.com";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."github.com" = {
      IdentityFile = "/run/secrets/ssh/github";
      IdentitiesOnly = true;
    };
  };
}
