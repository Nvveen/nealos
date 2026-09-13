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

      homeManagerDefaults = hostInputs: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inputs = hostInputs;
          inherit palette;
        };
      };

      commonInputs = {
        inherit (inputs)
          community-palettes
          disko
          lazyvim
          nix-cachyos-kernel
          noctalia
          silentSDDM
          sops-nix
          ;
      };
    in
    {
      nixosConfigurations.hyperv = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inputs = commonInputs // {
            inherit (inputs) vscode-server;
          };
          inherit palette;
        };
        modules = [
          ./hosts/hyperv
          home-manager.nixosModules.home-manager
          (homeManagerDefaults (commonInputs // { inherit (inputs) vscode-server; }))
        ];
      };

      # Live installer image. Does NOT import ./modules/common (it needs the
      # `inputs` specialArg); shared nix settings come via
      # modules/common/nix-settings.nix inside ./hosts/installer.
      nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./hosts/installer
          home-manager.nixosModules.home-manager
          (homeManagerDefaults {
          })
        ];
      };

      homeConfigurations.neal = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inputs = {
            inherit (inputs)
              community-palettes
              lazyvim
              noctalia
              ;
          };
          inherit palette;
        };
        modules = [
          ./users/neal/home.nix
        ];
      };

      packages.x86_64-linux.iso = self.nixosConfigurations.installer.config.system.build.isoImage;
    };
}
