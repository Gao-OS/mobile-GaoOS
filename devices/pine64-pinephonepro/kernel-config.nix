{ config, lib, pkgs, ... }:

{
  # Minimum driver hardware requirements
  mobile.kernel.structuredConfig = [
    (helpers: with helpers; {
      # eMMC
      MMC_SDHCI_OF_ARASAN = yes;

      # Display
      DRM_PANEL_HIMAX_HX8394 = yes;

      # Touch screen
      TOUCHSCREEN_GOODIX = yes;

      # General wireless
      WIRELESS = yes;

      # Bluetooth
      BT = yes;
      BT_HCIUART = yes;
      BT_HCIUART_BCM = yes;

      # Wifi (Broadcom brcmfmac for AP6255)
      WLAN = yes;
      WLAN_VENDOR_BROADCOM = yes;
      BRCMUTIL = yes;
      BRCMFMAC = yes;
      BRCMFMAC_SDIO = yes;
      # Note: BRCMSMAC removed - legacy 802.11n driver not needed for PPP
      # Note: BRCM_TRACING requires FTRACE which is intentionally disabled
      BRCMDBG = yes;
      MAC80211 = yes;

      # Sensors
      STK3310 = yes; # Light sensor

      # SPI Flash
      SPI = yes;
      SPI_ROCKCHIP = yes;
      MTD = yes;
      MTD_SPI_NOR = yes;

      # Keyboard
      IP5XXX_POWER = yes;
      KEYBOARD_PINEPHONE = yes;

      # Vibrate motor
      INPUT_GPIO_VIBRA = yes;
    })
  ];
}
