# Home-manager module applied to every user via home-manager.sharedModules.
{ lib, ... }:
{

  programs.starship = {
    enable = true;
    settings = {
      format = lib.concatStrings [
        "[░▒▓](#1a2520)"
        "[  ](bg:#1a2520 fg:#fdf6e3)"
        "[](bg:#007854 fg:#1a2520)"
        "$directory"
        "[](fg:#007854 bg:#1a6265)"
        "$git_branch"
        "$git_status"
        "[](fg:#1a6265 bg:#073642)"
        "$nodejs"
        "$rust"
        "$golang"
        "$php"
        "[](fg:#073642 bg:#002b36)"
        "$time"
        "[ ](fg:#002b36)"
        "\n$character"
      ];

      directory = {
        style = "fg:#fdf6e3 bg:#007854";
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
        style = "bg:#1a6265";
        format = "[[ $symbol $branch ](fg:#00a86b bg:#1a6265)]($style)";
      };

      git_status = {
        style = "bg:#1a6265";
        format = "[[($all_status$ahead_behind )](fg:#00a86b bg:#1a6265)]($style)";
      };

      nodejs = {
        symbol = "";
        style = "bg:#073642";
        format = "[[ $symbol ($version) ](fg:#0dbc79 bg:#073642)]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:#073642";
        format = "[[ $symbol ($version) ](fg:#0dbc79 bg:#073642)]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:#073642";
        format = "[[ $symbol ($version) ](fg:#0dbc79 bg:#073642)]($style)";
      };

      php = {
        symbol = "";
        style = "bg:#073642";
        format = "[[ $symbol ($version) ](fg:#0dbc79 bg:#073642)]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:#002b36";
        format = "[[  $time ](fg:#657b83 bg:#002b36)]($style)";
      };

      # Starship draws the mode indicator itself; its fish integration disables fish_mode_prompt.
      character = {
        vimcmd_symbol = "[N](bold green)";
        vimcmd_replace_symbol = "[R](bold purple)";
        vimcmd_replace_one_symbol = "[R](bold purple)";
        vimcmd_visual_symbol = "[V](bold yellow)";
      };
    };
  };
}
