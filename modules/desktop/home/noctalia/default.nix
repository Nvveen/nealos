{ pkgs, config, ... }:
let
  terminalSequences = import ./terminal-sequences.nix { inherit pkgs; };
in
{
  xdg.configFile."noctalia/settings.toml".source = pkgs.replaceVars ./settings.toml {
    avatarPath = "${config.home.homeDirectory}/.face.icon";
  };
  xdg.configFile."noctalia/hooks.toml".source = ./hooks.toml;
  xdg.configFile."noctalia/user-templates.toml".source = ./user-templates.toml;
  xdg.configFile."noctalia/terminal-sequences".source = terminalSequences;
}
