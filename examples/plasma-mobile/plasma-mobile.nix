#
# Minimum config used to enable Plasma Mobile.
#
{ config, lib, pkgs, ... }:

{
  mobile.beautification = {
    silentBoot = lib.mkDefault true;
    splash = lib.mkDefault true;
  };

  services.xserver.desktopManager.plasmaMobile.enable = true;

  services.pipewire.enable = lib.mkDefault true;
  services.pulseaudio.enable = lib.mkDefault false;
  networking.wireless.enable = lib.mkForce false;
  powerManagement.enable = true;
  services.displayManager.defaultSession = "plasma-mobile";
  services.displayManager.autoLogin.enable = true;
}
