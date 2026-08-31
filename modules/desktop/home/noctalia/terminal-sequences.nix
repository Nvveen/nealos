# foot has no live config reload, but it honours OSC escape sequences. Noctalia
# renders this template on every palette change and the post_hook tees the
# result into open ptys, so existing terminals recolour without restarting.
#
# Built rather than shipped as a static file because the content is raw control
# bytes (\033, \007), which a Nix string can't express — printf can.
{ pkgs }:
pkgs.runCommand "noctalia-terminal-sequences" { } ''
  {
    printf '\033]10;{{colors.terminal_foreground.default.hex}}\007'
    printf '\033]11;{{colors.terminal_background.default.hex}}\007'

    printf '\033]4;0;{{colors.terminal_normal_black.default.hex}}\007'
    printf '\033]4;1;{{colors.terminal_normal_red.default.hex}}\007'
    printf '\033]4;2;{{colors.terminal_normal_green.default.hex}}\007'
    printf '\033]4;3;{{colors.terminal_normal_yellow.default.hex}}\007'
    printf '\033]4;4;{{colors.terminal_normal_blue.default.hex}}\007'
    printf '\033]4;5;{{colors.terminal_normal_magenta.default.hex}}\007'
    printf '\033]4;6;{{colors.terminal_normal_cyan.default.hex}}\007'
    printf '\033]4;7;{{colors.terminal_normal_white.default.hex}}\007'

    printf '\033]4;8;{{colors.terminal_bright_black.default.hex}}\007'
    printf '\033]4;9;{{colors.terminal_bright_red.default.hex}}\007'
    printf '\033]4;10;{{colors.terminal_bright_green.default.hex}}\007'
    printf '\033]4;11;{{colors.terminal_bright_yellow.default.hex}}\007'
    printf '\033]4;12;{{colors.terminal_bright_blue.default.hex}}\007'
    printf '\033]4;13;{{colors.terminal_bright_magenta.default.hex}}\007'
    printf '\033]4;14;{{colors.terminal_bright_cyan.default.hex}}\007'
    printf '\033]4;15;{{colors.terminal_bright_white.default.hex}}\007'

    printf '\033]19;{{colors.terminal_selection_fg.default.hex}}\007'
    printf '\033]17;{{colors.terminal_selection_bg.default.hex}}\007'
    printf '\033]12;{{colors.terminal_cursor.default.hex}}\007'
  } > $out
''
