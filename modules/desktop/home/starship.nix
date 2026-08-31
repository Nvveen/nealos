# Starship's config is a single TOML file with no include mechanism, so
# noctalia renders the WHOLE config rather than injecting a palette: this
# module generates a template with {{colors...}} placeholders in place of
# hex values, and noctalia writes the result to STARSHIP_CONFIG.
#
# Requires the built-in starship template to be OFF in noctalia's settings.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfgPath = "${config.home.homeDirectory}/.local/share/starship/starship.toml";

  template = (pkgs.formats.toml { }).generate "starship.toml.tpl" (
    import ../../../dotfiles/starship/prompt.nix {
      inherit lib;
      c = {
        primary = "{{colors.primary.default.hex}}";
        onPrimary = "{{colors.on_primary.default.hex}}";
        secondary = "{{colors.secondary.default.hex}}";
        tertiary = "{{colors.tertiary.default.hex}}";
        outline = "{{colors.outline.default.hex}}";
        surface = "{{colors.surface.default.hex}}";
        surfaceVariant = "{{colors.surface_container.default.hex}}";
        onSurface = "{{colors.on_surface.default.hex}}";
        onSurfaceVariant = "{{colors.on_surface_variant.default.hex}}";
      };
    }
  );
in
{
  # dotfiles/starship writes a complete config for the portable case; here
  # noctalia owns the file, so home-manager must not also manage it.
  programs.starship.settings = lib.mkForce { };

  home.sessionVariables.STARSHIP_CONFIG = lib.mkForce cfgPath;
  systemd.user.sessionVariables.STARSHIP_CONFIG = lib.mkForce cfgPath;

  xdg.configFile."noctalia/starship.toml.tpl".source = template;
}
