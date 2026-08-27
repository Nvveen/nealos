{ inputs, lib, ... }:
let
  palettes = inputs.community-palettes;
  dirs = lib.attrNames (lib.filterAttrs (_: t: t == "directory") (builtins.readDir palettes));
  names = lib.filter (name: builtins.pathExists "${palettes}/${name}/${name}.json") dirs;
  slug = n: lib.toLower (builtins.replaceStrings [" "] ["-"] n);
  luaFor =
    name:
    let
      p = builtins.fromJSON (builtins.readFile "${palettes}/${name}/${name}.json");
      c = p.dark;
      hex = v: lib.removePrefix "#" v;
    in
    {
      "themes/${slug name}/colors.lua".text = ''
        return {
          primary = "${hex c.mPrimary}",
          surface = "${hex c.mSurface}",
        }
      '';
    };
in
{
  xdg.configFile = lib.mkMerge (map luaFor names);
}
