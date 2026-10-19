# Keep the Steam Frame USB dongle able to reach the headset's access point.
#
# The headset's AP is 6 GHz and WPA3-only.
#
# Without a regulatory domain the kernel boots with the world domain, which
# has no 6 GHz. wpa_supplicant then keeps the dongle's channel list without
# 6 GHz and never tries to associate.
#
# Steam (re)writes the "Steam Frame Wireless Adapter" profile with
# key-mgmt wpa-psk, which the AP rejects. Whenever a NetworkManager profile
# changes, switch that one back to sae; NetworkManager's next autoconnect
# attempt then succeeds.
{ pkgs, ... }:
let
  profile = "Steam Frame Wireless Adapter";
  nmcli = "${pkgs.networkmanager}/bin/nmcli";
in
{
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = "options cfg80211 ieee80211_regdom=CZ";

  systemd.paths.steam-frame-wifi-sae = {
    wantedBy = [ "multi-user.target" ];
    pathConfig.PathChanged = "/etc/NetworkManager/system-connections";
  };

  systemd.services.steam-frame-wifi-sae = {
    after = [ "NetworkManager.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      km=$(${nmcli} -g 802-11-wireless-security.key-mgmt con show '${profile}' 2>/dev/null) || exit 0
      if [ "$km" = wpa-psk ]; then
        ${nmcli} con modify '${profile}' 802-11-wireless-security.key-mgmt sae
      fi
    '';
  };
}
