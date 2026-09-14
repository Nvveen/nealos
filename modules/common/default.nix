# Settings that make sense on any target, including a live ISO: no bootloader,
# no filesystems, no disko, no sops.

{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # Previously only in users/authorized_keys.nix, which nothing imported —
  # new hosts got no authorized_keys.d/<user> file at all.
  imports = [
    ./authorized-keys.nix
    ./nix-settings.nix # caches + experimental-features, shared with the installer ISO
  ];

  boot.initrd.systemd.enable = true;

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
    ./home/shell
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
