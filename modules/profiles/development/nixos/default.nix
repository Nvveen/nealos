{ inputs, ... }:
{
  imports = [ inputs.vscode-server.nixosModules.default ];

  services.vscode-server.enable = true;

  home-manager.sharedModules = [ ../home ];
}
