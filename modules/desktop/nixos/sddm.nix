{
  inputs,
  lib,
  palette,
  pkgs,
  nealosSplash,
  ...
}:
let
  c = palette.colors;

  usersDir = ../../../users;

  # SDDM reads <user>.face.icon from FacesDir; store paths avoid the perms/homedir problems.
  avatars = lib.filterAttrs (_: p: builtins.pathExists p) (
    lib.mapAttrs (name: _: usersDir + "/${name}/files/avatar.png") (
      lib.filterAttrs (_: type: type == "directory") (builtins.readDir usersDir)
    )
  );

  facesDir = pkgs.runCommand "sddm-faces" { } ''
    mkdir -p $out
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: p: "cp ${p} $out/${name}.face.icon") avatars
    )}
  '';
in
{
  imports = [
    inputs.silentSDDM.nixosModules.default
  ];

  services.displayManager.sddm.settings.Theme = {
    CursorTheme = "Bibata-Modern-Classic";
    FacesDir = "${facesDir}";
  };

  environment.systemPackages = [ pkgs.bibata-cursors ];

  programs.silentSDDM = {
    enable = true;
    theme = "rei";
    backgrounds.jade = nealosSplash;
    settings = {
      # Backgrounds: referenced by FILENAME as copied into backgrounds/.
      # rei defaults to rei.mp4 for both screens.
      "LockScreen" = {
        background = "splash.png";
        blur = 0;
      };
      "LoginScreen".background = "splash.png";

      "LockScreen.Clock".color = c.mOnSurface;
      "LockScreen.Date".color = c.mOnSurfaceVariant;

      "LoginScreen.LoginArea.Avatar" = {
        active-border-color = c.mPrimary;
        inactive-border-color = c.mOutline;
      };

      "LoginScreen.LoginArea.Username".color = c.mOnSurface;

      # NOTE: every background-color below is paired with its opacity —
      # rei leaves most at 0.0, which makes the colour invisible.
      "LoginScreen.LoginArea.PasswordInput" = {
        content-color = c.mOnSurface;
        background-color = c.mSurfaceVariant;
        background-opacity = 1.0;
        border-color = c.mOutline;
      };

      "LoginScreen.LoginArea.LoginButton" = {
        background-color = c.mPrimary;
        background-opacity = 1.0;
        active-background-color = c.mHover;
        active-background-opacity = 1.0;
        content-color = c.mOnPrimary;
        active-content-color = c.mOnHover;
        border-color = c.mOutline;
      };

      "LoginScreen.LoginArea.Spinner".color = c.mOnSurface;

      "LoginScreen.LoginArea.WarningMessage" = {
        normal-color = c.mOnSurface;
        warning-color = c.mTertiary;
        error-color = c.mError;
      };

      "LoginScreen.MenuArea.Popups" = {
        background-color = c.mSurface;
        background-opacity = 1.0;
        active-option-background-color = c.mPrimary;
        active-option-background-opacity = 1.0;
        content-color = c.mOnSurface;
        active-content-color = c.mOnPrimary;
        border-color = c.mOutline;
      };

      "LoginScreen.MenuArea.Session" = {
        background-color = c.mPrimary;
        content-color = c.mOnSurface;
        active-content-color = c.mOnPrimary;
      };
      "LoginScreen.MenuArea.Layout" = {
        background-color = c.mPrimary;
        content-color = c.mOnSurface;
        active-content-color = c.mOnPrimary;
      };
      "LoginScreen.MenuArea.Keyboard" = {
        background-color = c.mPrimary;
        content-color = c.mOnSurface;
        active-content-color = c.mOnPrimary;
      };
      "LoginScreen.MenuArea.Power" = {
        background-color = c.mPrimary;
        content-color = c.mOnSurface;
        active-content-color = c.mOnPrimary;
      };

      "Tooltips" = {
        background-color = c.mSurface;
        background-opacity = 1.0;
        content-color = c.mOnSurface;
      };
    };
  };
}
