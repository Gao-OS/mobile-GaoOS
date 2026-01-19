{ pkgs, lib, ... }:

{
  nix.nixPath = [
    "nixpkgs=${lib.cleanSource pkgs.path}"
    # Mobile GaoOS root
    "mobile-gaoos=${lib.cleanSource ../../..}"
  ];
}
