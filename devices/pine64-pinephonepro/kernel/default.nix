{
  mobile-gaoos
, fetchurl
, ...
}:

mobile-gaoos.kernel-builder {
  version = "6.17.7";
  configfile = ./config.aarch64;

  src = fetchurl {
    url = "https://gitlab.com/pine64-org/linux/-/archive/ppp-6.17-20251104-2007/linux-ppp-6.17-20251104-2007.tar.gz";
    sha256 = "0xyyn52js3wbwqarxifm3g30y26g804x6qdva1bz33s0rymh68fv";
  };

  patches = [
    # USB Type-C: Enable OTG mode with role switching for gadget mode
    ./0001-arm64-dts-rockchip-set-type-c-dr_mode-as-otg.patch
    # LEDs: Green on at boot, red as panic indicator
    ./0001-dts-pinephone-pro-Setup-default-on-and-panic-LEDs.patch
    # DWC3: Allow userspace USB role control without debugfs
    ./0001-usb-dwc3-Enable-userspace-role-switch-control.patch
  ];

  postInstall = ''
    echo ":: Installing FDTs"
    mkdir -p $out/dtbs/rockchip
    cp -v "$buildRoot/arch/arm64/boot/dts/rockchip/rk3399-pinephone-pro.dtb" "$out/dtbs/rockchip/"
  '';

  isModular = false;
  isCompressed = false;
}
