# Colours for the runtime tier come from noctalia's templates, not from here.
# What this module still owns is the wallpaper artwork, which is ours rather
# than noctalia's and is tied to the build-time palette.
{ palette, ... }:
{
  imports = [
    ./firefox.nix
    ./gtk.nix
  ];

  qt = {
    enable = true;
    platformTheme.name = "kde";
  };

  xdg.configFile."themes/${palette.name}/backgrounds".source =
    ../../themes + "/${palette.name}/backgrounds";
}
