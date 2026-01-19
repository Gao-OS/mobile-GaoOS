# Notes about devices

![Devices taxonomy; System and Platform terms points to an optional Family term, which points to a Device term](devices-taxonomy.svg)

This document describes the terms used to describe a **device** within Mobile
GaoOS.

The terms are:

* Device
* (Family)
* Platform
* System

## Definitions

### What is a *system*?

A **system** describes the common peculiarities that are shared across the
different *devices* and *platforms*. Options may be present to describe
systemic differences or evolutionary changes in those systems' design.

Generally, a system describes the most basic requirements to boot devices,
without caring for details that are *platform*-specific or *device*-specific.

When talking about a *system*, they are commonly referred as *$system-based*.
For example, `asus-z00t` is an **android-based** system. Its `system.type` is
`android`.

Examples of systems:

* android-based (most devices shipping with Android)
* depthcharge-based (most devices shipping with ChromeOS)
* u-boot-based (a wide range, but mostly "hackable" hardware)

### What is a *platform*?

A **platform** describes the common features of a *SoC*[^1] disregarding the
*system* it is used with. It is entirely expected that a single *platform* is
used with a variety of *systems*.

[^1]: [System on a Chip](https://en.wikipedia.org/wiki/System_on_a_chip)

The *platform* should set as few global options as possible, the most likely,
and lone, option set should be the *system* used (e.g. `aarch64-linux`). A
*platform* will also toggle *quirks* on and off, which are deficiencies
that must be worked around specific to the *platform*.

Lastly, as an implementation detail, it is preferred to keep the platforms *as
precisely as possible*, making a distinct platform even if it is technically
the same as another one (e.g. *Rockchip RK3399* ⇆ *Rockchip OP-1*). This allows
better differentiation if, in the end, there is a tiny difference.

The names used should be the *technical* names, as best as possible. This is
why the *Qualcomm Snapdragon 615* is named *Qualcomm MSM8939*.

Examples of platforms:

* Allwinner A64
* Qualcomm MSM8939
* Qualcomm SDM660
* Rockchip OP-1

### What is a *device*?

A **device** is a *somewhat specific* description of a model of an *appliance* or
a *machine*. Generally speaking, when a single build boots on two different
*SKUs* without differentiation, they are the same *device*.

The `oneplus-oneplus3` and `oneplus-oneplus3t` is a single *device*.
Conversely, the `google-taimen` and `google-walleye` are *distinct devices*
requiring a different kernel build (or software handling via kernel modules).
The actual line where devices stop being devices and start becoming families is
undefined, and undefinable. Though following *the same kernel build boots them*
is likely a good differentiator.

When describing a device, a device is made by or for an *OEM* (e.g. ASUS,
Google), has a *name* (e.g. Zenfone 2 Laser, Pixel 2), and generally has a
*codename* (e.g. z00t, walleye). When talking about a device, it's better to
use the *$oem-$codename* pair (e.g. `asus-z00t`), as it describes the exact
device more appropriately. Some OEMs re-use device names (e.g. Moto G).
Additionally, those codenames are generally used to talk about the devices
with Android ROM development, it ends up being useful to find resources about
the device.

Examples of devices:

* ASUS Zenfone 2 Laser (`asus-z00t`)
* Google Pixel 2 (`google-walleye`)

### What are *families*?

First of all, **families** are optional. Most devices will directly be
implemented without a family in sight.

A family is best described as an *incomplete device*. Most of the device's
properties will be defined by the family, and only the last details will be
described by the device.

Following from the previous example, `google-walleye` and `google-taimen` are
different *devices* of the same *family*. They both are made by the same OEM,
and share most configuration. The main differences here are the display size,
and the kernel build used.

Examples of families:

* `google-wahoo`, the Pixel 2 (`taimen` and `walleye`)

## Implementation

### Do I need to implement a system type?

Probably not. You only need to implement a system type when your device has a
different boot chain not supported already.

If you do end up needing to implement a system type, they are under the
`modules/system-types` directory.

### How do I implement a platform?

First, you need to know whether you need to add a platform or not. All distinct
SoCs need their own option, see `modules/hardware-$manufacturer.nix`.

Look at existing platforms implemented, and copy the one that matches yours the
best. It is likely you only need to add an option to enable the platform, an
option for the system type, and enable the relevant quirks.

### How do I implement a device?

See the [Porting Guide](../porting-guide.md).

### How do I implement a family?

The easiest way is to implement two devices of your family, copy-paste and all,
and only after refactor the common parts out.

Families are found under the `devices/families` directory, one directory per
family. They should mirror the implementation of a device, but be incomplete,
expected to be completed by their devices.

## Implementation details

### Families

Families are not a module, like systems and platforms, as they would incur
additional cost during the evaluation for not much gain. Seen in another way,
families are an implementation detail of a device, and not an intrinsic part of
the architecture of the Mobile GaoOS project.
