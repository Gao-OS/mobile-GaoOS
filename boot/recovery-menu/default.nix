{ lib, mobile-gaoos }:

mobile-gaoos.mkLVGUIApp {
  name = "boot-recovery-menu.mrb";
  executablePath = "libexec/boot-recovery-menu.mrb";
  src = lib.cleanSource ./.;
  rubyFiles = [
    "${../lib}/hal/reboot_modes.rb"
    "${../lib}/init/configuration.rb"
    "main.rb"
  ];
}
