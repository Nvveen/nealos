{ ... }:
{
  imports = [
    ../../modules/common
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

        nix.settings.trusted-users = [
          "root"
          "nixos"
        ];

        # Stock installer behaviour: set a password with `passwd` on the
        # console, then SSH in from the host.
        services.openssh.settings = {
          PasswordAuthentication = true;
          KbdInteractiveAuthentication = true;
          PermitRootLogin = "yes";
        };

        image.baseName = lib.mkForce "nealos-installer";
        isoImage.volumeID = "NEALOS";
        isoImage.squashfsCompression = "zstd -Xcompression-level 3";

        # Optional: lets you SSH in without setting a password first.
        users.users.nixos.openssh.authorizedKeys.keys = [ ];
      }
    )
  ];
}
