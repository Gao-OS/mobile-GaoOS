{ lib, libinput }:

libinput.override ({
  wacomSupport = false;
  documentationSupport = false;
  eventGUISupport = false;
  testsSupport = false;
  valgrind = null;
} // lib.optionalAttrs (lib.functionArgs libinput.override ? luaSupport) {
  luaSupport = false;
})
