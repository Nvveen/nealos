# The prompt's shape and layout, shared by both starship modules.
#
# Colours are interpolated directly rather than going through starship's
# palette feature: as of starship 1.26.0, palette names resolve in module
# configs but NOT in the root `format` string, and this prompt's segments live
# almost entirely in `format`. Callers pass `c` as an attrset of colour
# strings — literal hex for the portable module, noctalia {{...}} placeholders
# for the desktop one.
{ lib, c }:
{
  # Segments run bright to dark, left to right.
  format = lib.concatStrings [
    "[░▒▓](${c.surfaceVariant})"
    "[  ](bg:${c.surfaceVariant} fg:${c.onPrimary})"
    "[](bg:${c.primary} fg:${c.surfaceVariant})"
    "$directory"
    "[](fg:${c.primary} bg:${c.outline})"
    "$git_branch"
    "$git_status"
    "[](fg:${c.outline} bg:${c.surfaceVariant})"
    "$nodejs"
    "$rust"
    "$golang"
    "$php"
    "[](fg:${c.surfaceVariant} bg:${c.surface})"
    "$time"
    "[ ](fg:${c.surface})"
    "\n$character"
  ];

  directory = {
    style = "fg:${c.onPrimary} bg:${c.primary}";
    format = "[ $path ]($style)";
    truncation_length = 3;
    truncation_symbol = "…/";
    substitutions = {
      "Documents" = "󰈙 ";
      "Downloads" = " ";
      "Music" = " ";
      "Pictures" = " ";
    };
  };

  git_branch = {
    symbol = "";
    style = "bg:${c.outline}";
    format = "[[ $symbol $branch ](fg:${c.onPrimary} bg:${c.outline})]($style)";
  };
  git_status = {
    style = "bg:${c.outline}";
    format = "[[($all_status$ahead_behind )](fg:${c.onPrimary} bg:${c.outline})]($style)";
  };

  nodejs = {
    symbol = "";
    style = "bg:${c.surfaceVariant}";
    format = "[[ $symbol ($version) ](fg:${c.tertiary} bg:${c.surfaceVariant})]($style)";
  };
  rust = {
    symbol = "";
    style = "bg:${c.surfaceVariant}";
    format = "[[ $symbol ($version) ](fg:${c.tertiary} bg:${c.surfaceVariant})]($style)";
  };
  golang = {
    symbol = "";
    style = "bg:${c.surfaceVariant}";
    format = "[[ $symbol ($version) ](fg:${c.tertiary} bg:${c.surfaceVariant})]($style)";
  };
  php = {
    symbol = "";
    style = "bg:${c.surfaceVariant}";
    format = "[[ $symbol ($version) ](fg:${c.tertiary} bg:${c.surfaceVariant})]($style)";
  };

  time = {
    disabled = false;
    time_format = "%R";
    style = "bg:${c.surface}";
    format = "[[  $time ](fg:${c.onSurfaceVariant} bg:${c.surface})]($style)";
  };

  # Starship draws the mode indicator itself; its fish integration disables
  # fish_mode_prompt. These use terminal colour names deliberately, so they
  # follow foot's palette rather than this one.
  character = {
    vimcmd_symbol = "[N](bold green)";
    vimcmd_replace_symbol = "[R](bold purple)";
    vimcmd_replace_one_symbol = "[R](bold purple)";
    vimcmd_visual_symbol = "[V](bold yellow)";
  };
}
