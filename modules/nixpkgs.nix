{ lib, ... }:

{
  nixpkgs.overlays = [
    (import ../overlay/overlay.nix)
    (import ../overlay/mruby-builder/overlay.nix)
  ];

  # Mobile devices commonly require proprietary firmware blobs.
  # Allow unfree packages so device firmware can be included in builds.
  nixpkgs.config.allowUnfree = lib.mkDefault true;
}
