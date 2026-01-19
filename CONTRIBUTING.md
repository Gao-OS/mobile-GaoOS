# Contributing to Mobile GaoOS

You don't need to write code to help contributing with Mobile GaoOS.

As Mobile GaoOS is a superset on top of NixOS, you should read the [contributing guidelines](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md) of the NixOS project. Many of the points apply just the same with Mobile GaoOS.

## Opening issues

Issues you face when using or working with Mobile GaoOS should be filed on [the project's issue tracker](https://github.com/Gao-OS/Mobile-GaoOS/issues).

First verify an existing, open, and recent issue matching your exact problem doesn't already exist. In case of doubt, always open a new issue. Sometimes vaguely reported symptoms are from different sources and it is easier to manage when different issues are opened.

When describing the issues you face, please provide the most information you can. For sharing logs, please share them as [Gists](https://gist.github.com/) so the issue does not get bogged down.

## Porting

See the [Device Porting Guide](doc/porting-guide.md).

Once a port has been made for a new device, [open a Pull Request](https://github.com/Gao-OS/Mobile-GaoOS/pulls).

## Packaging software

Unless it is related to the abstraction of device specifics, packaging should be done upstream at the [Nixpkgs](https://github.com/NixOS/nixpkgs) project.

Mobile GaoOS is a superset of NixOS, all the software that is in NixOS is available for Mobile GaoOS.
