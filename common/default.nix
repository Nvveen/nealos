{ pkgs, lib, ... }:

{
  imports = [ ./desktop.nix ];

  boot.initrd.systemd.enable = true;
  boot.loader.timeout = 0;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;

  services.tuned.enable = lib.mkDefault true;
  services.upower.enable = lib.mkDefault true;

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

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Packages every machine gets. To search: nix search nixpkgs <term>
  environment.systemPackages = with pkgs; [
    btop
    ddcutil # brightness control
    firefox
    git
    jq
    nixd
    nixfmt
    pywalfox-native # firefox with plugin
    ripgrep
    wget
  ];

  # Only helps locally rendered terminals; SSH/VS Code clients need the font installed themselves.
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  # Required so fish lands in /etc/shells and gets its system-wide completions/vendor setup.
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  home-manager.sharedModules = [
    ../home
    ./hypr
    ./noctalia
  ];
  home-manager.backupFileExtension = "bak";

  # Lets unpatched dynamically linked binaries run (VS Code servers, language servers, ...)
  programs.nix-ld.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.vscode-server.enable = true;
}
