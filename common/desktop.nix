# Minimal Wayland desktop: Hyprland (via UWSM) with SDDM as the greeter.
{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  environment.systemPackages = [ pkgs.foot ];
}
