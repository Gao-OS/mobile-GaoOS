# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Mobile GaoOS is a superset of NixOS Linux that abstracts device-specific differences to run NixOS on mobile devices ("NixOS, on your phone"). It uses the Nix module system extensively. All device hardware differences are abstracted behind `mobile.*` module options.

**Important**: Mobile GaoOS only builds against the **unstable** branch of Nixpkgs.

## Flake Commands (Recommended)

### Building a Device Image

```bash
nix build .#nixosConfigurations.<device>-<example>.config.mobile.outputs.default
```

### Available Configurations

- `oneplus-enchilada-{hello,phosh}`
- `pine64-pinephonepro-{hello,phosh,installer}`

### Development Shell

```bash
nix develop  # Provides: autoport, android-tools, dtc, mkbootimg, binwalk, etc.
```

### Packages

```bash
nix build .#autoport    # Device porting helper tool
nix build .#docs        # Project documentation
```

### Using as a Flake Input

```nix
{
  inputs.mobile-gaoos.url = "github:Gao-OS/Mobile-GaoOS";
  outputs = { nixpkgs, mobile-gaoos, ... }: {
    nixosConfigurations.myphone = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        mobile-gaoos.nixosModules.default
        mobile-gaoos.nixosModules.pine64-pinephonepro
        ./configuration.nix
      ];
    };
  };
}
```

## Legacy Build Commands

```bash
# Build the default output for a device
nix-build --argstr device <device-name> -A outputs.default

# Build an example system
nix-build examples/hello --argstr device <device-name> -A outputs.default

# Build with a custom configuration via local.nix
nix-build --argstr device <device-name> -A outputs.default

# Dev shell
nix-shell
```

## Available Devices

Device names match directory names under `devices/`:
- `oneplus-enchilada` (OnePlus 6, Android-based, SDM845 SoC)
- `pine64-pinephonepro` (Pine64 PinePhone Pro, U-Boot based, RK3399S SoC)

### Helper Scripts (in bin/)

- `bin/menuconfig` - Interactive kernel configuration
- `bin/kernel-normalize-config` - Normalize kernel config files
- `bin/ssh-initrd` - SSH into initrd for debugging
- `bin/remote-boot` - Remote boot testing

## Architecture

### Evaluation Chain

Two entry points converge on the same evaluation logic:

1. **Flake path**: `flake.nix` → `lib/release-tools.nix` `evalWith` → NixOS `eval-config.nix`
2. **Legacy path**: `default.nix` → `lib/eval-with-configuration.nix` → `lib/release-tools.nix` `evalWith` → NixOS `eval-config.nix`

`evalWith` is the core function that combines Mobile GaoOS modules (`modules/module-list.nix`) with NixOS modules and device configuration. It uses `pkgs.path` to locate NixOS's own module list.

Key files:
- `lib/release-tools.nix` - Defines `evalWith`, `all-devices`, and cross-compilation helpers
- `lib/eval-with-configuration.nix` - CLI shim that parses `--argstr device` and calls `evalWith`
- `release.nix` - Hydra CI builds (reused by `flake.nix` `hydraJobs`)

### Directory Structure

```
devices/          Device-specific hardware configs (default.nix per device)
modules/          60+ NixOS modules for mobile features
  system-types/   Boot output plugins: android, u-boot, uefi, depthcharge
boot/             Stage-1 boot GUI (mruby + lvgui): splash, recovery, script-loader
overlay/          3 Nixpkgs overlays (main, boot assets, mruby-builder)
examples/         Complete system configs: hello, phosh, plasma-mobile, installer
lib/              Evaluation helpers (release-tools.nix, eval-with-configuration.nix)
doc/              Documentation sources (Markdown, built with Nix)
artwork/          Logos and wallpapers
bin/              Developer helper scripts
```

### System Types

Devices declare `mobile.system.type` which determines boot output format:
- `android` - Android boot image (fastboot-flashable, used by oneplus-enchilada)
- `u-boot` - U-Boot bootloader images (used by pine64-pinephonepro)
- `uefi` - UEFI bootable images
- `depthcharge` - ChromeOS depthcharge format

Each system type is a plugin under `modules/system-types/` that defines `mobile.outputs.default` and type-specific outputs.

### Module System

60+ modules in `modules/module-list.nix` (keep `:sort`ed when adding). Key module groups:

- **Boot**: `boot.nix`, `bootloader.nix`, `boot-control.nix`, `stage-0.nix`
- **Initrd**: `initrd.nix`, `initrd-base.nix`, `initrd-kernel.nix`, `initrd-boot-gui.nix`, `initrd-network.nix`, `initrd-ssh.nix`, `initrd-usb.nix`
- **Hardware**: `hardware-soc.nix`, `hardware-screen.nix`, `hardware-ram.nix`, SoC-specific modules (`hardware-qualcomm.nix`, `hardware-rockchip.nix`, etc.)
- **Storage**: `disk-image.nix`, `generated-disk-images.nix`, `generated-filesystems.nix`, `rootfs.nix`
- **Device**: `mobile-device.nix`, `devices-metadata.nix`, `system-types.nix`
- **Features**: `usb-gadget.nix`, `adb.nix`, `zram.nix`, `luks.nix`, `beautification.nix`

### Overlays

Three overlays composed in order:
1. `overlay/overlay.nix` - Main overlay (mobile-gaoos packages, kernel packages, firmware)
2. `overlay/mruby-builder/overlay.nix` - MRuby cross-compilation toolchain
3. `overlay/boot/overlay.nix` - Boot GUI assets (applied within modules, not in flake)

### Key Module Options

Device configs typically set:
- `mobile.device.name`, `mobile.device.identity`
- `mobile.hardware.soc` - SoC identifier (maps to hardware modules)
- `mobile.hardware.ram`, `mobile.hardware.screen`
- `mobile.system.type` - Boot output format
- `mobile.boot.stage-1.kernel.package` - Device kernel
- `mobile.usb.*` - USB gadget configuration

### Cross-Compilation

From x86_64-linux, images are automatically cross-compiled for aarch64-linux. The system detects architecture differences via `lib/release-tools.nix` `knownSystems` mapping and configures `crossSystem` accordingly.

## Adding a New Device

1. Create `devices/<vendor>-<device>/default.nix`
2. Set hardware specs: `mobile.hardware.soc`, `mobile.hardware.ram`, `mobile.hardware.screen`
3. Configure the kernel: `mobile.boot.stage-1.kernel.package`
4. Set the system type: `mobile.system.type` (`android`, `u-boot`, `uefi`, or `depthcharge`)
5. Add the device to `flake.nix` `nixosConfigurations`
6. Use `nix develop` and the `autoport` tool for assistance

Refer to existing devices (`pine64-pinephonepro`, `oneplus-enchilada`) as templates.

## Conventions

- Module list in `modules/module-list.nix` must stay `:sort`ed
- Device directories are named `<vendor>-<device>` (e.g., `pine64-pinephonepro`)
- Example configs go in `examples/<name>/configuration.nix`
- The `mobile.*` option namespace is used for all Mobile GaoOS options
- Default user is `gao` with password `2580` and passwordless sudo via wheel group
