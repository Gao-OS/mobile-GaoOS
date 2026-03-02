#
# NixOS module for Plasma Mobile (Plasma 6).
#
# This module enables the Plasma Mobile shell on top of Plasma 6,
# installs mobile-specific packages, and asserts that required services
# (NetworkManager, Bluetooth, PipeWire/PulseAudio) are enabled.
#
{ config, lib, pkgs, ... }:

let
  cfg = config.services.xserver.desktopManager.plasmaMobile;
in
{
  options.services.xserver.desktopManager.plasmaMobile = {
    enable = lib.mkEnableOption "Plasma Mobile shell (Plasma 6)";

    installRecommendedSoftware = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install recommended KDE mobile applications.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Plasma 6 as the base desktop environment
    services.desktopManager.plasma6.enable = true;

    # Register the plasma-mobile Wayland session
    services.displayManager.sessionPackages = [
      pkgs.kdePackages.plasma-mobile
    ];

    # Core mobile packages
    environment.systemPackages = with pkgs.kdePackages; [
      plasma-mobile
      plasma-nano
      plasma-dialer
      plasma-keyboard
      spacebar
      maliit-framework
      maliit-keyboard
    ] ++ lib.optionals cfg.installRecommendedSoftware (with pkgs.kdePackages; [
      alligator
      angelfish
      audiotube
      calindori
      kalk
      kasts
      kclock
      keysmith
      koko
      krecorder
      ktrip
      kweather
    ]);

    # Sensible defaults for a mobile device
    hardware.bluetooth.enable = lib.mkDefault true;
    networking.networkmanager.enable = lib.mkDefault true;
    hardware.sensor.iio.enable = lib.mkDefault true;

    # Assertions to catch misconfiguration early
    assertions = [
      {
        assertion = config.networking.networkmanager.enable;
        message = "Plasma Mobile requires NetworkManager. Set `networking.networkmanager.enable = true`.";
      }
      {
        assertion = config.hardware.bluetooth.enable;
        message = "Plasma Mobile requires Bluetooth. Set `hardware.bluetooth.enable = true`.";
      }
      {
        assertion = config.services.pipewire.enable || config.services.pulseaudio.enable;
        message = "Plasma Mobile requires an audio server. Enable PipeWire or PulseAudio.";
      }
    ];
  };
}
