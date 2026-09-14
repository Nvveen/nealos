{ nixpkgs, ... }:
{
  imports = [

    "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    # Caches, keys and experimental-features for the LIVE environment, so a
    # freshly booted ISO substitutes instead of building from source.
    ../../modules/common/nix-settings.nix
    (
      { pkgs, lib, ... }:
      {
        environment.systemPackages = with pkgs; [
          rsync
          git
          sops
          age
          ssh-to-age
        ];

        users.users.root = {
          initialHashedPassword = lib.mkForce null;
          password = "root";
        };

        # "nixos" is the live ISO's default user; without this the daemon
        # drops substituters passed on the command line by non-root users.
        nix.settings.trusted-users = [
          "root"
          "nixos"
        ];

        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = true;
            KbdInteractiveAuthentication = true;
            PermitRootLogin = lib.mkForce "yes";
          };
        };

        image.baseName = lib.mkForce "nealos-installer";
        isoImage.volumeID = "NEALOS";
        isoImage.squashfsCompression = "zstd -Xcompression-level 3";
      }
    )
  ];
}
