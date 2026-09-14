# modules/common/home/starship/default.nix — new
{ lib, palette, ... }:
{
  programs.starship.enable = true;
  programs.starship.settings = import ./prompt.nix {
    inherit lib;
    # palette JSON uses mPrimary-style fields; prompt.nix wants bare names
    c = {
      primary = palette.colors.mPrimary;
      onPrimary = palette.colors.mOnPrimary;
      secondary = palette.colors.mSecondary;
      tertiary = palette.colors.mTertiary;
      outline = palette.colors.mOutline;
      surface = palette.colors.mSurface;
      surfaceVariant = palette.colors.mSurfaceVariant;
      onSurface = palette.colors.mOnSurface;
      onSurfaceVariant = palette.colors.mOnSurfaceVariant;
    };
  };
}
