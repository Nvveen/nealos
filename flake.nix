{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs"; # this line is optional, prevents downloading two versions of nixpkgs but disables cache
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      vscode-server,
      nix-cachyos-kernel,
      ...
    }@inputs:
    {
      nixosConfigurations.nealxos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/hyperv
          ./common
          ./user
          vscode-server.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          {
            nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ];
            nix.settings.substituters = [
              "https://attic.xuyh0120.win/lantian"
              "https://noctalia.cachix.org"
            ];
            nix.settings.trusted-public-keys = [
              "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
              "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
            ];
          }
        ];
      };
      homeConfigurations.neal = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./home
          {
            home.username = "neal";
            home.homeDirectory = "/home/neal";
            home.stateVersion = "26.05";
          }
        ];
      };
    };
}
