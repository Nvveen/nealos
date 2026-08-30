# Home-manager module applied to every user via home-manager.sharedModules.
{ pkgs, ... }:

let
  shellAliases = {
    l = "ls -alh";
    ll = "ls -l";
    ls = "ls --color=tty";
    grep = "grep --color=auto";
    egrep = "egrep --color=auto";
    fgrep = "fgrep --color=auto";
  };
in
{
  home.packages = with pkgs; [
    fd # find, but sane defaults and gitignore-aware
    ripgrep # grep, fast, gitignore-aware
    bat # cat with syntax highlighting
    eza # ls with colours and --tree
    dust # du that shows what's actually big
    sd # sed without the escaping
    delta # diff viewer, used by lazygit
    lazygit
  ];

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

      ls = "eza";
      ll = "eza -l --git";
      la = "eza -la --git";
      lt = "eza --tree --level=2";
      cat = "bat";
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

  programs.delta.enable = true;
  programs.delta.enableGitIntegration = true;

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };
}
