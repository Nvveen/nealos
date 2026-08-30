{ config, ... }:
{
  imports = [
    ./shell.nix
    ./starship.nix
    ./nvim
  ];
  home.sessionVariables = {
    NEALXOS_THEME = "osaka-jade";
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
  };
}
