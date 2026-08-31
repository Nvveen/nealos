# Portable starship: home-manager owns the whole config, colours baked in from
# lib/palette.nix. On a NixOS desktop this is superseded by
# modules/desktop/home/starship.nix, which has noctalia render the same prompt
# so it follows runtime theme changes.
{ palette, lib, ... }:
let
  p = palette.colors;
in
{
  programs.starship = {
    enable = true;
    settings = import ./prompt.nix {
      inherit lib;
      c = {
        primary = p.mPrimary;
        onPrimary = p.mOnPrimary;
        secondary = p.mSecondary;
        tertiary = p.mTertiary;
        outline = p.mOutline;
        surface = p.mSurface;
        surfaceVariant = p.mSurfaceVariant;
        onSurface = p.mOnSurface;
        onSurfaceVariant = p.mOnSurfaceVariant;
      };
    };
  };
}
