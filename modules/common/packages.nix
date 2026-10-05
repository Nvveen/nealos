# CLI packages every machine gets. Shared between NixOS hosts (system packages)
# and standalone home-manager (home packages). To search: nix search nixpkgs <term>
pkgs: with pkgs; [
  btop
  file
  git
  jq
  nixd
  nixfmt
  ripgrep
  sops
  ssh-to-age
  wget
]