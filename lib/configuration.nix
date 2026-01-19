# This file is intended to be included in your system's `configuration.nix`.
# Given a device name, it will import the appropriate device configuration, and
# all the modules from Mobile GaoOS.
#
# Assuming NIX_PATH contains `mobile-gaoos`:
#
# ```
# {
#   imports = [
#     (import <mobile-gaoos/lib/configuration.nix> { device = "xxx-yyy"; })
#   ];
# }
# ```

{ device ? null }:

{
  imports =
    (
      if device == null
      then []
      else [ (import (../devices + "/${device}")) ]
    )
    ++ import ../modules/module-list.nix
  ;
}
