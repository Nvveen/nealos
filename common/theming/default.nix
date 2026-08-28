{ inputs, lib, ... }:
let
  palettes = inputs.community-palettes;

  dirs = lib.attrNames (lib.filterAttrs (_: t: t == "directory") (builtins.readDir palettes));
  names = lib.filter (name: builtins.pathExists "${palettes}/${name}/${name}.json") dirs;

  slug = n: lib.toLower (builtins.replaceStrings [ " " ] [ "-" ] n);

  luaFor =
    name:
    let
      p = builtins.fromJSON (builtins.readFile "${palettes}/${name}/${name}.json");
      c = p.dark;
      hex = v: lib.removePrefix "#" v;
      s = slug name;
      localDir = ./themes + "/${s}/backgrounds";
    in
    (
      {
        "themes/${s}/colors.lua" = {
          text = ''
            return {
              primary = "${hex c.mPrimary}",
              surface = "${hex c.mSurface}",
            }
          '';
        };
      }
      // lib.optionalAttrs (builtins.pathExists localDir) {
        "themes/${s}/backgrounds".source = localDir;
      }
    );
in
{
  xdg.configFile = lib.mkMerge (map luaFor names);
}
