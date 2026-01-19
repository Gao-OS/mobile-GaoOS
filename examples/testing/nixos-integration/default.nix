{ pkgs ? (import ../../../pkgs.nix {})
}:

let
  eval = configuration: import (pkgs.path + "/nixos") {
    configuration = {
      imports = [ configuration ];
    };
  };

  # A "clean" NixOS eval
  nixos-eval = eval {
    imports = [
      ./configuration.nix
    ];
  };
  # A Mobile GaoOS eval that should be a no-op
  mobile-gaoos-eval = eval {
    imports = [
      ./configuration.nix
      (import ../../../lib/configuration.nix { })
    ];
    mobile.enable = false;
  };
  # A Mobile GaoOS eval that should be a no-op
  mobile-gaoos-stage-1-eval = eval {
    imports = [
      ./configuration.nix
      (import ../../../lib/configuration.nix { })
    ];
    mobile.enable = false;
    mobile.boot.stage-1.enable = true;
  };
in
  {
    inherit
      nixos-eval
      mobile-gaoos-eval
      mobile-gaoos-stage-1-eval
    ;

    # Use this output to check that the product works as expected.
    # (The bogus rootfs will be overriden by the VM config.)
    default =
      assert nixos-eval.config.system.build.toplevel == mobile-gaoos-eval.config.system.build.toplevel;
      assert nixos-eval.config.system.build.vm == mobile-gaoos-eval.config.system.build.vm;
      mobile-gaoos-eval.config.system.build.vm
    ;

    mobile-gaoos-stage-1 = mobile-gaoos-stage-1-eval.config.system.build.vm;
  }
