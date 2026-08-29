{ inputs, pkgs, ... }:
let
  p = builtins.fromJSON (builtins.readFile "${inputs.community-palettes}/Osaka jade/Osaka jade.json");
  c = p.dark;
in
{
  imports = [
    inputs.silentSDDM.nixosModules.default
  ];

  services.displayManager.sddm.settings.Theme.CursorTheme = "Bibata-Modern-Classic";

  programs.silentSDDM = {
    enable = true;
    theme = "rei";
    backgrounds.jade = ./themes/osaka-jade/backgrounds/osaka-jade-bg.jpg;
    settings = {
      # Backgrounds: referenced by FILENAME as copied into backgrounds/.
      # rei defaults to rei.mp4 for both screens.
      "LockScreen" = {
        background = "osaka-jade-bg.jpg";
        blur = 0; # rei sets 32
      };
      "LoginScreen".background = "osaka-jade-bg.jpg";

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
