{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
    mkOption
    types
  ;
  inherit (lib.systems)
    elaborate
  ;
  cfg = config.mobile.system;

  # The host platform selected by the Mobile device configuration
  deviceHostPlatform = elaborate cfg.system;

  # Use JSON to escape values for printing
  e = builtins.toJSON;
in
{
  options.mobile = {
    system.system = mkOption {
      # Known supported target types.
      type = types.enum [
        "aarch64-linux"
        "armv7l-linux"
        "x86_64-linux"
      ];
      description = ''
        Defines the host platform architecture the device is.

        This will automagically setup cross-compilation where possible.
      '';
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.system == pkgs.stdenv.targetPlatform.system;
        message = ''
          pkgs.stdenv.targetPlatform.system expected to be ${e cfg.system}, is ${e pkgs.stdenv.targetPlatform.system}
              nixpkgs.buildPlatform → ${e config.nixpkgs.buildPlatform.system}
              nixpkgs.hostPlatform → ${e config.nixpkgs.hostPlatform.system}
        '';
      }
    ];

    nixpkgs.hostPlatform =
      mkDefault deviceHostPlatform
    ;
  };
}
