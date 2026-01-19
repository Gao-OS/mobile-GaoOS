final: super:
let
  inherit (final)
    callPackage
  ;
in
# NOTE: This overlay is scoped to only be used in practice by `mobile-gaoos.stage-1`.
#       See `overlay/overaly.nix` for how it's used.
{
  mobile-gaoos = super.mobile-gaoos // {
    stage-1 = {
      # Inherits the script-loader now customized with the slimmed deps.
      inherit (final.mobile-gaoos) script-loader;
      boot-recovery-menu = callPackage ../recovery-menu {};
      boot-error = callPackage ../error {};
      boot-splash = callPackage ../splash {};
    };
  };

  # Slimmed-down for stage-1 usage.
  libinput = callPackage ./libinput {
    inherit (super)
      libinput
    ;
  };

  # Slimmed-down for stage-1 usage.
  libxkbcommon = callPackage ./libxkbcommon {
    inherit (super)
      libxkbcommon
    ;
  };
}
