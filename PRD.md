# PRD: Kernel Migration from postmarketOS

## Executive Summary

Migrate kernel work from postmarketOS to Mobile GaoOS to bring devices to full working state. This involves updating kernels from 6.4.x to 6.16-6.17, importing updated configs, and packaging necessary userspace components.

## Current State

| Component | Mobile GaoOS | postmarketOS | Gap |
|-----------|-------------|--------------|-----|
| **OnePlus 6 Kernel** | 6.4.0 | 6.16.7 | 12 major versions |
| **PinePhone Pro Kernel** | 6.4.7 | 6.17.7 | 13 major versions |
| **SDM845 Firmware** | commit `3ec855b` | commit `176ca71` | Multiple updates |
| **Hexagon DSP Support** | None | hexagonrpcd 0.3.2+ | Missing |
| **Modem Support (SDM845)** | None | pd-mapper, q6voiced | Missing |
| **Modem Support (PPP)** | None | eg25-manager 0.4.2+ | Missing |

## Goals

1. **Primary**: Update kernels to match postmarketOS versions
2. **Secondary**: Package userspace daemons required for hardware functionality
3. **Tertiary**: Maintain feature parity with postmarketOS device support

## Scope

### In Scope

- Kernel version updates for both supported devices
- Kernel config migrations
- Firmware updates
- Essential userspace daemon packaging
- UCM audio configuration updates

### Out of Scope

- Adding new device support
- Desktop environment packaging (Phosh/Plasma Mobile already exist)
- pmtest/diagnostic tooling

---

## Phase 1: PinePhone Pro Kernel Update

**Priority**: High
**Complexity**: Low (no patches required in postmarketOS)

### Current State

```
devices/pine64-pinephonepro/kernel/default.nix
├── version: 6.4.7
├── source: pine64-org/linux @ ppp-6.4-20230801-1055
├── patches: 3 local patches
└── config: config.aarch64 (6.4.x based)
```

### Target State

```
devices/pine64-pinephonepro/kernel/default.nix
├── version: 6.17.7
├── source: pine64-org/linux @ ppp-6.17-20251104-2007
├── patches: None (evaluate if existing patches still needed)
└── config: Updated for 6.17.x
```

### Tasks

- [ ] Update kernel source to `ppp-6.17-20251104-2007`
- [ ] Download and adapt postmarketOS kernel config
- [ ] Evaluate existing patches (may be upstreamed)
- [ ] Update `kernel-config.nix` structured config if needed
- [ ] Test boot and basic functionality
- [ ] Update firmware packages (linux-firmware-brcm, linux-firmware-rockchip)

### Dependencies

| Package | Purpose | postmarketOS Version |
|---------|---------|---------------------|
| eg25-manager | Modem management | >= 0.4.2 |
| alsa-ucm-conf | Audio profiles | >= 1.2.6.2 |
| linux-firmware-brcm | WiFi/BT | Latest |
| linux-firmware-rockchip | Display | Latest |

---

## Phase 2: OnePlus 6 (SDM845) Kernel Update

**Priority**: High
**Complexity**: Medium (requires userspace daemons)

### Current State

```
devices/families/sdm845-mainline/kernel/default.nix
├── version: 6.4.0
├── source: sdm845-mainline/linux @ sdm845-6.4-r1
├── patches: 1 (tas2559 audio codec fix)
└── config: config.aarch64 (6.4.x based)

devices/oneplus-enchilada/firmware/default.nix
├── source: sdm845-mainline/firmware-oneplus-sdm845 @ 3ec855b
└── includes postmarketos firmware paths
```

### Target State

```
devices/families/sdm845-mainline/kernel/default.nix
├── version: 6.16.7
├── source: sdm845-mainline/linux @ sdm845-6.16.7-r0
├── patches: 1 (xiaomi-beryllium compatibility)
└── config: Updated for 6.16.x

devices/oneplus-enchilada/firmware/default.nix
├── source: sdm845-mainline/firmware-oneplus-sdm845 @ 176ca71
└── sensor firmware subpackage
```

### Tasks

- [ ] Update kernel source to `sdm845-6.16.7-r0`
- [ ] Download and adapt postmarketOS kernel config
- [ ] Import xiaomi-beryllium DTS compatibility patch
- [ ] Remove old tas2559 patch (likely upstreamed)
- [ ] Update firmware to latest commit
- [ ] Test boot and basic functionality

### Dependencies

| Package | Purpose | Status in Nixpkgs |
|---------|---------|-------------------|
| hexagonrpcd | Hexagon DSP RPC daemon | **Needs packaging** |
| pd-mapper | Protection Domain mapper | **Needs packaging** |
| q6voiced | Voice call audio routing | **Needs packaging** |
| rmtfs | Remote filesystem service | Available |
| alsa-ucm-conf-sdm845 | Audio profiles | **Needs packaging** |

---

## Phase 3: Userspace Daemon Packaging

**Priority**: Medium
**Complexity**: High

### Required New Packages

#### 1. hexagonrpcd

```
Purpose: Hexagon DSP communication daemon
Source: https://gitlab.com/postmarketOS/hexagonrpcd
Required for: Audio DSP, sensors, camera
```

#### 2. pd-mapper (qrtr)

```
Purpose: Qualcomm Protection Domain service mapper
Source: https://github.com/linux-msm/pd-mapper
Required for: Modem, audio services
```

#### 3. q6voiced

```
Purpose: Voice call audio routing
Source: https://gitlab.com/postmarketOS/q6voiced
Required for: Phone calls on SDM845
```

#### 4. eg25-manager

```
Purpose: Quectel EG25 modem management
Source: https://gitlab.com/mobian1/eg25-manager
Required for: PinePhone Pro cellular
Status: May exist in nixpkgs, verify version
```

### UCM Audio Configs

Both devices need updated ALSA UCM (Use Case Manager) profiles:

- **PinePhone Pro**: `alsa-ucm-conf` profiles for HiFi + VoiceCall
- **SDM845**: Custom `alsa-ucm-conf-sdm845` package

---

## Phase 4: Integration & Testing

### Test Matrix

| Feature | PinePhone Pro | OnePlus 6 |
|---------|---------------|-----------|
| Boot to GUI | | |
| WiFi | | |
| Bluetooth | | |
| Audio (speakers) | | |
| Audio (headphones) | | |
| Modem (calls) | | |
| Modem (SMS) | | |
| Modem (data) | | |
| Camera | | |
| GPS | | |
| Sensors | | |
| Suspend/Resume | | |

### CI/Build Testing

- [ ] Cross-compile from x86_64 for aarch64
- [ ] Native aarch64 build
- [ ] Boot image generation
- [ ] Installer image generation (PinePhone Pro only)

---

## Technical Notes

### Kernel Config Migration Strategy

postmarketOS uses Alpine's Clang toolchain; Mobile GaoOS uses Nix's GCC. Config differences:

```diff
- CONFIG_CC_IS_CLANG=y
+ CONFIG_CC_IS_GCC=y
```

**Strategy**: Download postmarketOS config, run through `make olddefconfig` with Nix toolchain to adapt.

### Firmware Handling

postmarketOS extracts firmware from GitLab repos. Current Mobile GaoOS approach is compatible but needs:

1. Updated commit references
2. Sensor firmware subpackage for SDM845
3. Proper licensing metadata (`meta.license = lib.licenses.unfree`)

### Patch Management

| Patch | Status | Action |
|-------|--------|--------|
| PPP: type-c dr_mode | Check if upstreamed | Test without, remove if working |
| PPP: LED setup | Check if upstreamed | Test without, remove if working |
| PPP: dwc3 role switch | Check if upstreamed | Test without, remove if working |
| SDM845: tas2559 fix | Likely upstreamed in 6.16 | Remove |
| SDM845: beryllium DTS | Required | Import from postmarketOS |

---

## Success Criteria

1. **Phase 1 Complete**: PinePhone Pro boots with 6.17.x kernel, WiFi/BT/Audio working
2. **Phase 2 Complete**: OnePlus 6 boots with 6.16.x kernel, WiFi/BT/Audio working
3. **Phase 3 Complete**: Modem functionality on both devices
4. **Phase 4 Complete**: All features in test matrix verified

---

## Resources

### postmarketOS Repositories

- Kernel SDM845: https://gitlab.postmarketos.org/postmarketOS/pmaports/-/tree/master/device/community/linux-postmarketos-qcom-sdm845
- Kernel PPP: https://gitlab.postmarketos.org/postmarketOS/pmaports/-/tree/master/device/community/linux-pine64-pinephonepro
- Device OnePlus 6: https://gitlab.postmarketos.org/postmarketOS/pmaports/-/tree/master/device/community/device-oneplus-enchilada
- Device PPP: https://gitlab.postmarketos.org/postmarketOS/pmaports/-/tree/master/device/community/device-pine64-pinephonepro
- Firmware SDM845: https://gitlab.com/sdm845-mainline/firmware-oneplus-sdm845

### Upstream Kernel Sources

- SDM845 Mainline: https://gitlab.com/sdm845-mainline/linux
- Pine64 Linux: https://gitlab.com/pine64-org/linux

### Userspace Daemons

- hexagonrpcd: https://gitlab.com/postmarketOS/hexagonrpcd
- pd-mapper: https://github.com/linux-msm/pd-mapper
- q6voiced: https://gitlab.com/postmarketOS/q6voiced
- eg25-manager: https://gitlab.com/mobian1/eg25-manager

---

## Timeline Estimate

| Phase | Scope | Dependencies |
|-------|-------|--------------|
| Phase 1 | PinePhone Pro kernel | None |
| Phase 2 | OnePlus 6 kernel | None |
| Phase 3 | Userspace daemons | Phase 1 & 2 for testing |
| Phase 4 | Integration testing | Phase 1, 2, 3 |

**Recommended order**: Phase 1 → Phase 2 → Phase 3 → Phase 4

Start with PinePhone Pro as it's simpler (no Qualcomm userspace complexity).
