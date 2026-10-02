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
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
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

      mkHost =
        {
          hostName,
          extraInputs ? { },
        }:
        let
          hostInputs = commonInputs // extraInputs;
        in
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inputs = hostInputs;
            inherit palette;
          };
          modules = [
            ./hosts/${hostName}
            home-manager.nixosModules.home-manager
            (homeManagerDefaults hostInputs)
          ];
        };

    in
    {
      nixosConfigurations.hyperv = mkHost {
        hostName = "hyperv";
        extraInputs = { inherit (inputs) vscode-server; };
      };

      nixosConfigurations.nealdesk = mkHost {
        hostName = "nealdesk";
        extraInputs = { inherit (inputs) lanzaboote vscode-server; };
      };

      nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit nixpkgs; };
        modules = [
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
          ./users/neal/user.nix
          ./users/neal/dotfiles
        ];
      };

      homeConfigurations.devcontainer = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs palette;
        };
        modules = [
          ./users/neal/user.nix
          ./users/neal/dotfiles
          ./hosts/devcontainer
        ];
      };

      packages.x86_64-linux.devcontainer = self.homeConfigurations.devcontainer.activationPackage;
      # Base tools every NixOS host gets, for the devcontainer's global profile.
      packages.x86_64-linux.devcontainer-system-tools =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          nixos =
            (nixpkgs.lib.nixosSystem {
              modules = [ { nixpkgs.hostPlatform = "x86_64-linux"; } ];
            }).config.environment;
          common = import ./modules/common {
            inherit pkgs;
            inherit (nixpkgs) lib;
            inputs = commonInputs;
          };
        in
        pkgs.buildEnv {
          name = "nealos-system-tools";
          paths = nixos.corePackages ++ nixos.defaultPackages ++ common.environment.systemPackages;
          pathsToLink = [ "/bin" "/sbin" ];
          ignoreCollisions = true;
        };
      packages.x86_64-linux.iso = self.nixosConfigurations.installer.config.system.build.isoImage;
    };
}
