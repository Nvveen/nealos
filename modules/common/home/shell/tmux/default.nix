{ lib, pkgs, ... }:
let
  lazyTmux = pkgs.callPackage ./package.nix { };
  tmux = lib.getExe pkgs.tmux;
  lazy = lib.getExe lazyTmux;
  autoStart = ''
    if [[ -z "''${TMUX-}" && "''${NEALOS_NO_TMUX-}" != 1 && -n "''${TERM-}" && "$TERM" != dumb && -t 0 && -t 1 ]]; then
      ${tmux} new-session -A -s main
    fi
  '';
in
{
  imports = [ ./theme.nix ];

  home.packages = [ lazyTmux ];
  home.shellAliases = {
    ltm = "lazy-tmux";
  };

  programs.tmux = {
    enable = true;
    shortcut = "a";
    # Containers and plain SSH sessions need not have a systemd runtime directory.
    secureSocket = false;
    terminal = "tmux-256color";
    baseIndex = 1;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    mouse = true;
    focusEvents = true;
    historyLimit = 10000;

    extraConfig = ''
      set -g renumber-windows on
      bind c new-window -c "#{pane_current_path}"
      bind _ split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      bind f display-popup -w 80% -h 80% -E '${lazy} picker'
      bind C-s run-shell '${lazy} save --all && ${tmux} display-message "All sessions saved"'
    '';
  };

  programs.bash = {
    enable = true;
    initExtra = lib.mkAfter autoStart;
  };
  programs.zsh.initContent = lib.mkAfter autoStart;
  programs.fish.interactiveShellInit = lib.mkAfter ''
    if test -z "$TMUX"; and test "$NEALOS_NO_TMUX" != 1; and test -n "$TERM"; and test "$TERM" != dumb; and isatty stdin; and isatty stdout
      ${tmux} new-session -A -s main
    end
  '';
}
