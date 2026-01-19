# Lenovo Chromebook Duet

## Device-specific notes

### Developer mode

For more details the [Firmware Menu Interface](https://chromium.googlesource.com/chromiumos/docs/+/master/debug_buttons.md#Firmware-Menu-Interface) section from the upstream documentation can be read.

You will need to:

1. Boot in *Recovery mode* by powering on using `Power` + `Volume-Up` + `Volume-Down`
2. Activate Developer mode by pressing `Volume-Up` and `Volume-Down` simultaneously

Note that this is only to allow you to boot unverified images.

You may want to configure other options with GBB flags. This is left as an
exercise to the reader.
