# Package groups shared by NixOS hosts, standalone home-manager, the installer,
# and nealbox. To search: nix search nixpkgs <term>
pkgs:
let
  shared = with pkgs; [
    git
    openssh
    sops
    ssh-to-age
  ];
in
{
  common = shared ++ (with pkgs; [
    age
    btop
    file
    jq
    nixd
    nixfmt
    ripgrep
    rsync
    wget
  ]);

  # The container also includes the common group through its Home Manager path.
  container = with pkgs; [
    curl
    procps
    less
    lsof
    zip
    unzip
    xz
    iproute2
    iputils
  ];
}