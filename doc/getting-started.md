# Getting Started

## Using the guided installer

For a limited set of devices, there is a guided installer that can be used
to do your first-time install.

The device page for the supported devices will describe the requirements
for the installer.

* [Pine64 PinePhone Pro](devices/pine64-pinephonepro.md)

## Other options

This guide assumes the user knows how to prepare their device for development
use. These instructions are device-dependent, but not specific to Mobile GaoOS.

Briefly said, the device's bootloader must be unlocked, meaning that it allows
running custom-built operating system images.

The project is hosted under the [Mobile GaoOS organization](https://github.com/Gao-OS/),
as [Mobile-GaoOS](https://github.com/Gao-OS/Mobile-GaoOS).

### Getting the sources

Depending on your configuration, for users with a GitHub account and the proper
ssh configuration.

```
$ git clone git@github.com:Gao-OS/Mobile-GaoOS.git
```

Or, for everyone else.

```
$ git clone https://github.com/Gao-OS/Mobile-GaoOS.git
```

Nothing else! Everything required is self-contained.

If you're interested in testing with a device not-yet-approved, you will have
to roll up your sleeves and checkout the relevant branch for the PRs.
The [GitHub help article](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/checking-out-pull-requests-locally) may help.

## Compiling and Running

This is where it becomes harder to make a simple guide. These are different,
heterogeneous, hardware platforms, with different quirks, compilation steps,
and mainly, installation steps.

Fear not, look for your particular device on the [devices list](devices/index.md)
page, will likely contain the necessary instructions.

### Using a known-good revision

Things change, and sometimes things break. This is even more true with Mobile
GaoOS as the project depends on another moving target, NixOS.

The npins reference will be updated from time-to-time, but any breakage with
`nixos-unstable` is a bug, and should be fixed.

## Customizing

You probably will want to toggle options and such things when fiddling with
Mobile GaoOS, at first. The repository is structured in a way to allow you to
add options to an untracked `local.nix` file. The default `nix-build`
invocations will respect the content of that file as your configuration.

A sample `local.nix`.

```nix
{ lib, ... }:

{
  # Disables splash screens during boot
  mobile.boot.stage-1.splash.enable = false;
}
```

As Mobile GaoOS is a superset on top of NixOS, all NixOS options can be used in
this configuration file, though take note that most NixOS options will only
affect the stage-2 (rootfs, system.img) build.

The [Options list](options/index.md) page will be useful, as it provides an
overview of all the Mobile GaoOS specific options.

## Using in your system configuration

As the Mobile GaoOS configuration may include fixes and quirks for your device,
it is useful to include its configuration into your system's
`configuration.nix`.

Assuming your `NIX_PATH` includes `mobile-gaoos=/path/to/mobile-gaoos` you can
import the Mobile GaoOS configuration for your device by doing the following.

```nix
# configuration.nix
{
  # "xxx-yyy" is your device "Identifier" from https://Gao-OS.github.io/Mobile-GaoOS/devices,
  # e.g. "google-marlin".
  imports = [
    (import <mobile-gaoos/lib/configuration.nix> { device = "xxx-yyy"; })
    # ...
  ];

  # ...
  # Other configurations...
  # ...
}
```

While it is possible, it is discouraged to directly import the configuration
files from the `examples` directories. They may change in ways breaking your
system configuration. It is recommended to copy and edit the configuration
files from the `examples` directories if you are basing your configuration off
of an example.

## Contributing

This is a big topic, and not something about getting started! Though, quickly
noted, contributions are currently handled through GitHub pull requests.

If you are unable or unwilling to use GitHub for pull requests, you can e-mail
contributions, following the usual git via e-mail contribution workflow, to my
e-mail address, which you will find attached to commits I authored.

Note that there are more in-depth guides about specific contribution topics.

* [Contributing Guide](../CONTRIBUTING.md)
* [Device Porting Guide](porting-guide.md)
