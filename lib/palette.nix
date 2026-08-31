# The build-time palette. Used by anything that must know its colours before a
# user session exists (SDDM, Plymouth) or that can't follow noctalia at runtime
# (the shell prompt).
#
# Runtime theming — Hyprland, foot, GTK, Firefox, neovim — does NOT come from
# here. Noctalia owns that, and switching palette in its UI retheme those live.
# Switching the build-time tier means changing `default` below and rebuilding.
{ inputs, lib }:
let
  repo = inputs.community-palettes;

  # Change this to reskin SDDM, Plymouth and the prompt.
  default = "Osaka jade";

  slug = n: lib.toLower (builtins.replaceStrings [ " " ] [ "-" ] n);
in
{
  name = slug default;
  colors = (builtins.fromJSON (builtins.readFile "${repo}/${default}/${default}.json")).dark;
}
