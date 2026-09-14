# Nix daemon settings shared by real hosts AND the live installer ISO.
# Kept free of specialArgs (no `inputs`) so the installer can import it
# without the overlays/packages the rest of modules/common drags in.
{ ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Setting `substituters` REPLACES the built-in default, so cache.nixos.org
  # must be listed explicitly or it silently disappears.
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
    "https://attic.xuyh0120.win/lantian"
    "https://noctalia.cachix.org"
  ];

  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
  ];
}
