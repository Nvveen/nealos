{ ... }:

{
  users.users."neal" = {
    isNormalUser = true;
    description = "Neal van Veen";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    # packages = with pkgs; [ ];
  };

  home-manager.users."neal" = import ./home.nix;
}
