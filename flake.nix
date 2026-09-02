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
    };
    community-palettes = {
      url = "github:noctalia-dev/community-palettes";
      flake = false;
    };
    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lazyvim = {
      url = "github:pfassina/lazyvim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      palette = import ./lib/palette.nix {
        inherit inputs;
        inherit (nixpkgs) lib;
      };

      homeManagerDefaults = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs palette; };
      };
    in
    {
      nixosConfigurations.nealos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs palette; };
        modules = [
          ./hosts/hyperv
          home-manager.nixosModules.home-manager
          homeManagerDefaults
        ];
      };

      # Live installer image. Deliberately imports only ./modules/common: no
      # bootloader, no disko, no sops.
      nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs palette; };
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./hosts/installer
          home-manager.nixosModules.home-manager
          homeManagerDefaults
        ];
      };

      homeConfigurations.neal = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs palette; };
        modules = [
          ./users/neal/home.nix
        ];
      };

      packages.x86_64-linux.iso = self.nixosConfigurations.installer.config.system.build.isoImage;
    };
}
