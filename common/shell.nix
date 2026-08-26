# Home-manager module applied to every user via home-manager.sharedModules.
{ lib, pkgs, ... }:

let
  shellAliases = {
    l = "ls -alh";
    ll = "ls -l";
    ls = "ls --color=tty";
  };
in
{
  programs.fish = {
    enable = true;
    inherit shellAliases;

    # Abbreviations expand in place, so history keeps the real command.
    shellAbbrs = {
      gst = "git status";
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate";
      gp = "git push";
      gpl = "git pull";

      nrs = "sudo nixos-rebuild switch --flake ~/nealxos#nealxos";
      nrt = "sudo nixos-rebuild test --flake ~/nealxos#nealxos";
      nfu = "nix flake update --flake ~/nealxos";
    };

    interactiveShellInit = ''
      set -g fish_greeting ""

      fish_vi_key_bindings

      # zsh's vi mode keeps the common emacs motions usable in insert mode; fish drops them.
      bind -M insert \ca beginning-of-line
      bind -M insert \ce end-of-line
      bind -M insert \cw backward-kill-word
      bind -M insert \cu backward-kill-line
      bind -M insert \cp up-or-search
      bind -M insert \cn down-or-search

      set -g fish_cursor_default block
      set -g fish_cursor_insert line
      set -g fish_cursor_replace_one underscore
      set -g fish_cursor_visual block
    '';

    plugins = [
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "puffer";
        src = pkgs.fishPlugins.puffer.src;
      }
      {
        name = "sponge";
        src = pkgs.fishPlugins.sponge.src;
      }
    ];
  };

  # Fallback for the things that still drop into bash (scripts, remote tooling).
  programs.bash = {
    enable = true;
    inherit shellAliases;
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
  };

  programs.fzf.enable = true;
  programs.zoxide.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

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
