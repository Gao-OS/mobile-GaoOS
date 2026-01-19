# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Mobile GaoOS is a superset of NixOS Linux that abstracts device-specific differences to run NixOS on mobile devices ("NixOS, on your phone"). It uses the Nix module system extensively.

**Important**: Mobile GaoOS only builds against the **unstable** branch of Nixpkgs.

## Build Commands

### Building for a Device

```bash
# Build the default output for a device
nix-build --argstr device <device-name> -A outputs.default

# Build an example system (hello is recommended for cross-compilation testing)
nix-build examples/hello --argstr device <device-name> -A outputs.default

# Build with a custom configuration using local.nix
# Create ./local.nix with your NixOS configuration, then:
nix-build --argstr device <device-name> -A outputs.default
```

### Available Devices

Device names match directory names under `devices/`:
- `pine64-pinephone`, `pine64-pinephonepro`, `pine64-pinetab`
- `motorola-potter`, `oneplus-enchilada`, `oneplus-fajita`
- `asus-dumo`, `lenovo-krane`, `lenovo-wormdingler`
- `acer-juniper`, `acer-lazor`
- `uefi-x86_64` (generic UEFI systems)

### Example Systems

```bash
# Phosh (GNOME-based mobile shell)
nix-build examples/phosh --argstr device <device-name> -A outputs.default

# Plasma Mobile
nix-build examples/plasma-mobile --argstr device <device-name> -A outputs.default

# Installer image
nix-build examples/installer --argstr device <device-name> -A outputs.default
```

### Development Shell

```bash
nix-shell  # Provides: autoport, android-tools, dtc, mkbootimg, binwalk, etc.
```

### Helper Scripts (in bin/)

- `bin/menuconfig` - Interactive kernel configuration
- `bin/kernel-normalize-config` - Normalize kernel config files
- `bin/ssh-initrd` - SSH into initrd for debugging
- `bin/remote-boot` - Remote boot testing

## Architecture

### Directory Structure

- **`devices/`** - Device-specific configurations; each device has a `default.nix` with hardware specs, kernel, and firmware
- **`modules/`** - NixOS modules for mobile features (initrd, boot stages, hardware abstraction, USB gadget modes)
- **`overlay/`** - Nixpkgs overlay with mobile-specific packages
- **`boot/`** - Stage-1 boot components (splash, recovery menu, script loader using mruby-lvgui)
- **`examples/`** - Complete system configurations (hello, phosh, plasma-mobile, installer)
- **`lib/`** - Evaluation helpers (`eval-with-configuration.nix`, `release-tools.nix`)

### System Types

Devices declare a system type in `mobile.system.type` that determines boot outputs:
- `android` - Android boot image format
- `u-boot` - U-Boot bootloader
- `depthcharge` - ChromeOS depthcharge
- `uefi` - Standard UEFI boot

### Evaluation Entry Points

- `default.nix` - Main entry point, supports `--argstr device <name>` and optional `local.nix`
- `lib/eval-with-configuration.nix` - Core evaluation logic
- `lib/release-tools.nix` - CI/release build helpers
- `release.nix` - Hydra CI builds (not for typical use)

### Key Module Options

Device configs typically set:
- `mobile.device.name`, `mobile.device.identity`
- `mobile.hardware.soc`, `mobile.hardware.ram`, `mobile.hardware.screen`
- `mobile.system.type`
- `mobile.boot.stage-1.kernel.package`
- `mobile.usb.*` for USB gadget configuration

### Cross-Compilation

From x86_64-linux, you can cross-compile for:
- `aarch64-linux`
- `armv7l-linux`

The system auto-detects cross-compilation needs based on device architecture.

## Adding a New Device

1. Create `devices/<vendor>-<device>/default.nix`
2. Set hardware specifications (SoC, RAM, screen dimensions)
3. Configure the kernel package
4. Set the appropriate system type
5. Use `nix-shell` and the `autoport` tool for assistance

Refer to existing devices like `pine64-pinephone` as templates.
