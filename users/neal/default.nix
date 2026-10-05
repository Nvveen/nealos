{ ... }:
{
  users.users."neal" = {
    isNormalUser = true;
    description = "Neal van Veen";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  home-manager.users."neal" = {
    imports = [
      ./user.nix
      ./dotfiles
    ];
  };
}