{ pkgs, ... }: {
  home.packages = with pkgs; [
    fd          # find, but sane defaults and gitignore-aware
    ripgrep     # grep, fast, gitignore-aware
    bat         # cat with syntax highlighting
    eza         # ls with colours and --tree
    dust        # du that shows what's actually big
    sd          # sed without the escaping
    delta       # diff viewer, used by lazygit
    lazygit

  ];
}