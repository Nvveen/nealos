# Settings that make sense on any target, including a live ISO: no bootloader,
# no filesystems, no disko, no sops.

{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  boot.initrd.systemd.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.substituters = [
    "https://attic.xuyh0120.win/lantian"
    "https://noctalia.cachix.org"
  ];

  nix.settings.trusted-public-keys = [
    "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
  ];

  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];

  nixpkgs.config.allowUnfree = true;

  services.tuned.enable = lib.mkDefault true;

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # Packages every machine gets. To search: nix search nixpkgs <term>
  environment.systemPackages = with pkgs; [
    btop
    git
    jq
    nixd
    nixfmt
    ripgrep
    sops
    ssh-to-age
    wget
  ];

  # Required so fish lands in /etc/shells and gets its system-wide completions/vendor setup.
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  home-manager.sharedModules = [
    ../../dotfiles
  ];
  home-manager.backupFileExtension = "bak";

  # Lets unpatched dynamically linked binaries run (VS Code servers, language servers, ...)
  programs.nix-ld.enable = true;

  # mkDefault so the installer ISO can restore stock password login.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      KbdInteractiveAuthentication = lib.mkDefault false;
      PermitRootLogin = lib.mkDefault "no";
    };
  };

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 30d --keep 5";
    };
  };
}
