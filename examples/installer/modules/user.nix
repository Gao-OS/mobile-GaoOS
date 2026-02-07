{ lib, ... }:

{
  users.users.gao = {
    isNormalUser = true;
    password = "2580";
    extraGroups = [
      "input"
      "networkmanager"
      "video"
      "wheel"
    ];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = lib.mkForce false;
  };

  # Some systems allows the use of TTYs, e.g. the pinephone does.
  # Let's not make it needlessly annoying to use for them.
  services.getty.autologinUser = "gao";
}
