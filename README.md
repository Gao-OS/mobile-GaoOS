<div align="center"><a href="https://Gao-OS.github.io/Mobile-GaoOS/"><img src="artwork/logo/logo.svg" alt="Mobile GaoOS" title="Mobile GaoOS" width="500" height="130" /></a></div>

**Mobile GaoOS** is a superset on top of [NixOS Linux](https://nixos.org/nixos/),
[Nixpkgs](https://nixos.org/nixpkgs/) and [Nix](https://nixos.org/nix/),
aiming to abstract away the differences between *mobile* devices.

In four words: *"NixOS, on your phone"*.

> **Note**: Mobile GaoOS only builds against the **unstable** branch of Nixpkgs.

## Quick Start (Flake)

### Prerequisites

- Nix with [flakes enabled](https://nixos.wiki/wiki/Flakes)
- An `x86_64-linux` or `aarch64-linux` build host

### Building an Image

```bash
# Clone the repository
git clone https://github.com/Gao-OS/Mobile-GaoOS.git
cd Mobile-GaoOS

# Build a device image (PinePhone Pro with Phosh shell)
nix build .#nixosConfigurations.pine64-pinephonepro-phosh.config.mobile.outputs.default

# Build a device image (OnePlus 6 with Plasma Mobile)
nix build .#nixosConfigurations.oneplus-enchilada-plasma-mobile.config.mobile.outputs.default
```

The resulting image will be in `./result/`.

### Available Configurations

| Configuration | Device | Shell |
|---|---|---|
| `oneplus-enchilada-hello` | OnePlus 6 | Demo/test GUI |
| `oneplus-enchilada-phosh` | OnePlus 6 | Phosh (GNOME) |
| `oneplus-enchilada-plasma-mobile` | OnePlus 6 | Plasma Mobile |
| `pine64-pinephonepro-hello` | PinePhone Pro | Demo/test GUI |
| `pine64-pinephonepro-phosh` | PinePhone Pro | Phosh (GNOME) |
| `pine64-pinephonepro-plasma-mobile` | PinePhone Pro | Plasma Mobile |
| `pine64-pinephonepro-installer` | PinePhone Pro | Guided installer |

### Development Shell

```bash
nix develop
```

Provides: `autoport`, `android-tools`, `dtc`, `mkbootimg`, `binwalk`, and more.

### Building Packages

```bash
nix build .#autoport    # Device porting helper tool
nix build .#docs        # Project documentation
```

## Using as a Flake Input

Add Mobile GaoOS to your own flake to build a custom phone configuration:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    mobile-gaoos.url = "github:Gao-OS/Mobile-GaoOS";
  };

  outputs = { nixpkgs, mobile-gaoos, ... }: {
    nixosConfigurations.myphone = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        mobile-gaoos.nixosModules.default
        (mobile-gaoos + "/devices/pine64-pinephonepro")
        ./configuration.nix
      ];
    };
  };
}
```

Then in your `configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  # Your custom NixOS configuration
  users.users.gao = {
    isNormalUser = true;
    password = "2580";
    extraGroups = [ "wheel" "networkmanager" "video" "dialout" "feedbackd" ];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Pick your shell environment
  # For Phosh:
  imports = [ (mobile-gaoos + "/examples/phosh/phosh.nix") ];
  services.xserver.desktopManager.phosh.user = "gao";

  # Common mobile defaults
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.pipewire.enable = true;
  zramSwap.enable = true;
}
```

Build with:

```bash
nix build .#nixosConfigurations.myphone.config.mobile.outputs.default
```

## Flake Outputs Reference

| Output | Description |
|---|---|
| `overlays.default` | Nixpkgs overlay with mobile-specific packages |
| `nixosModules.default` | NixOS module set for mobile features |
| `devShells.*.default` | Development shell with porting tools |
| `packages.*.autoport` | Device porting helper |
| `packages.*.docs` | Project documentation |
| `nixosConfigurations.*` | Pre-built device + shell combinations |

## Supported Devices

| Device | SoC | System Type | Notes |
|---|---|---|---|
| [OnePlus 6](devices/oneplus-enchilada/) (`oneplus-enchilada`) | SDM845 | `android` | Requires OxygenOS 11 firmware |
| [PinePhone Pro](devices/pine64-pinephonepro/) (`pine64-pinephonepro`) | RK3399S | `u-boot` | Requires [Tow-Boot on SPI](https://tow-boot.org/devices/pine64-pinephonePro.html) |

### Flashing

**PinePhone Pro** (full disk image):

```bash
nix build .#nixosConfigurations.pine64-pinephonepro-phosh.config.mobile.outputs.disk-image
dd if=result of=/dev/mmcblkX bs=8M oflag=sync,direct status=progress
```

Hold *volume down* during boot to boot from SD card when using Tow-Boot.

**OnePlus 6** (boot image):

```bash
nix build .#nixosConfigurations.oneplus-enchilada-phosh.config.mobile.outputs.default
fastboot flash boot result
```

## Legacy (Non-Flake) Usage

The classic `nix-build` interface is still supported:

```bash
# Build with nix-build
nix-build --argstr device pine64-pinephonepro -A outputs.default

# Build an example
nix-build examples/phosh --argstr device pine64-pinephonepro -A outputs.default

# Custom config via local.nix
nix-build --argstr device pine64-pinephonepro -A outputs.default

# Development shell
nix-shell
```

## Cross-Compilation

From `x86_64-linux`, images are automatically cross-compiled for:
- `aarch64-linux` (PinePhone Pro, OnePlus 6)

No extra configuration needed. The build system detects architecture differences and sets up cross-compilation automatically.

## Adding a New Device

1. Create `devices/<vendor>-<device>/default.nix`
2. Set hardware specs (`mobile.hardware.soc`, `mobile.hardware.ram`, `mobile.hardware.screen`)
3. Configure the kernel package (`mobile.boot.stage-1.kernel.package`)
4. Set the system type (`mobile.system.type`: `android`, `u-boot`, or `uefi`)
5. Add the device to `flake.nix` `nixosConfigurations`

Use `nix develop` and the `autoport` tool for assistance. Refer to existing devices as templates.

## Project Structure

```
devices/          Device-specific hardware configurations
modules/          NixOS modules (initrd, boot, hardware abstraction, USB gadget)
overlay/          Nixpkgs overlay with mobile-specific packages
boot/             Stage-1 boot components (splash, recovery, script loader)
examples/         Complete system configurations (hello, phosh, plasma-mobile, installer)
lib/              Evaluation helpers
doc/              Documentation sources
artwork/          Logos and wallpapers
```

## Documentation

* [About Mobile GaoOS](doc/about.md)
* [Mobile GaoOS website](https://Gao-OS.github.io/Mobile-GaoOS/) - rendered documentation

As a superset of NixOS:

* [NixOS Manual](https://nixos.org/nixos/manual)
* [Nixpkgs Manual](https://nixos.org/nixpkgs/manual/)
* [Nix Manual](https://nixos.org/nix/manual)

## Contributing

* [Contributing to Mobile GaoOS](CONTRIBUTING.md)
* [Contributing to Nixpkgs](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md)

## License

Mobile GaoOS is licensed under the [MIT License](LICENSE).

> The MIT license applies to the files in this repository (expressions, scripts, modules),
> not to the packages built. Patches and derivative work are covered by their respective licenses.

## Acknowledgements

This project was funded in part through the NGI PET Fund.
[Read more on NLnet's website](https://nlnet.nl/PET/).

[![NGI0](doc/images/NGI0_tag_black_mono.svg)](https://nlnet.nl/NGI0/)
