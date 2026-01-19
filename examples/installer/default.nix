# Ensure CLI passes down arguments
{ ... }@args:

import ../../lib/eval-with-configuration.nix (args // {
  configuration = [ (import ./configuration.nix) ];
  additionalHelpInstructions = { device }: ''
    The build output to choose depends on the target.

    Pine64 PinePhone Pro and other u-boot devices:

      $ nix-build examples/installer --argstr device ${device} -A outputs.default

    App "simulator":

      $ nix-build examples/installer --argstr device pine64-pinephonepro -A outputs.app-simulator
  '';
})
