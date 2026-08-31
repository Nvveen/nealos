{
  palette,
  lib,
  pkgs,
  ...
}:
let
  c = palette.colors;
  g = import ./geometry.nix;

  # Plymouth's two-step module wants 0xRRGGBB; the palette gives #RRGGBB.
  ply = v: "0x" + lib.removePrefix "#" v;

  fontsConf = pkgs.makeFontsConf { fontDirectories = [ pkgs.redhat-official-fonts ]; };

  env = {
    FONTCONFIG_FILE = fontsConf;
    TPL = ./.;

    SURFACE = c.mSurface;
    SURFACEVARIANT = c.mSurfaceVariant;
    ONSURFACE = c.mOnSurface;
    OUTLINE = c.mOutline;
    PRIMARY = c.mPrimary;
    TERTIARY = c.mTertiary;

    PLY_SURFACE = ply c.mSurface;
    PLY_OUTLINE = ply c.mOutline;
    PLY_PRIMARY = ply c.mPrimary;

    CANVAS = toString g.canvas;
    XLEFT = toString g.xLeft;
    XRIGHT = toString g.xRight;
    YTOP = toString g.yTop;
    YBOTTOM = toString g.yBottom;
    STROKE = toString g.strokeWidth;
    WORDY = toString g.wordY;
    WORDSIZE = toString g.wordSize;
    WORDTRACK = toString g.wordTracking;
    SPLASHSCALE = toString g.splashScale;
    SPLASHX = toString g.splashX;
    SPLASHY = toString g.splashY;
  };

  theme =
    pkgs.runCommand "nealos-plymouth"
      (
        env
        // {
          nativeBuildInputs = [
            pkgs.resvg
            pkgs.oxipng
            pkgs.envsubst
            pkgs.gawk
          ];
        }
      )
      ''
        export OUTDIR=$out/share/plymouth/themes/nealos
        bash ${./build.sh}
      '';

  # Full-screen still, same mark, for the SDDM background.
  # Named splash.png because silentSDDM copies derivations by their `name`.
  splash =
    pkgs.runCommand "splash.png"
      (
        env
        // {
          nativeBuildInputs = [
            pkgs.resvg
            pkgs.oxipng
            pkgs.envsubst
            pkgs.gawk
          ];
        }
      )
      ''
        XMID=$(awk "BEGIN{print ($XLEFT+$XRIGHT)/2}") envsubst < ${./splash.svg.tpl} > s.svg
        resvg s.svg $out
        oxipng -o 4 --strip safe $out
      '';
in
{
  boot.plymouth = {
    enable = true;
    theme = "nealos";
    themePackages = [ theme ];
  };

  _module.args.nealosSplash = splash;
}
