{ pkgs, ... }:

{
  imports = [ ./nixos ];

  environment.systemPackages = [ pkgs.bibata-cursors ];
}
