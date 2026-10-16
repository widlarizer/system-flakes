# Stop udev from restarting wpa_supplicant whenever a Wi-Fi interface
# appears or disappears.
#
# nixpkgs adds that udev rule whenever networking.wireless.interfaces is
# empty. Under NetworkManager, wpa_supplicant starts with no interfaces
# (autoDetectInterfaces = false) and NetworkManager attaches them over
# D-Bus, so the restart buys nothing. It also races NetworkManager: plugging
# in the Steam Frame USB dongle (or booting with it plugged in) left the
# dongle's supplicant interface stuck ("Couldn't initialize supplicant
# interface: Name owner lost"), and every plug/unplug dropped wlp16s0 too.
#
# This loads a copy of the upstream module that only adds the rule when
# wpa_supplicant detects interfaces itself.
{ modulesPath, ... }:
let
  file = "services/networking/wpa_supplicant.nix";
  upstream = builtins.readFile (modulesPath + "/${file}");
  patched = builtins.replaceStrings
    [ "services.udev.extraRules = optionalString (cfg.interfaces == [ ])" ]
    [ "services.udev.extraRules = optionalString (cfg.interfaces == [ ] && cfg.autoDetectInterfaces)" ]
    upstream;
in
{
  disabledModules = [ file ];
  imports = [
    (if patched == upstream
     then throw "wpa-supplicant-no-restart.nix: upstream ${file} changed, update or drop this override"
     else builtins.toFile "wpa_supplicant.nix" patched)
  ];
}
