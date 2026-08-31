{ ... }:

{
  imports = [ ../../dotfiles ];

  home.username = "neal";
  home.homeDirectory = "/home/neal";

  # Keep in sync with the initial home-manager release used for this user.
  home.stateVersion = "26.05";

  programs.git = {
    settings.user = {
      name = "Neal van Veen";
      email = "nealvanveen@gmail.com";
    };
  };
}
