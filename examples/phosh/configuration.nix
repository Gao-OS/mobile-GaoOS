{ config, lib, pkgs, ... }:

let
  defaultUserName = "gao";
in
{
  imports = [
    ./phosh.nix
    ../common-configuration.nix
  ];

  config = {
    users.users."${defaultUserName}" = {
      isNormalUser = true;
      password = "2580";
      extraGroups = [
        "dialout"
        "feedbackd"
        "networkmanager"
        "video"
        "wheel"
      ];
    };

    security.sudo = {
      enable = true;
      wheelNeedsPassword = lib.mkForce false;
    };
    
    services.xserver.desktopManager.phosh = {
      user = defaultUserName;
    };
  };
}
