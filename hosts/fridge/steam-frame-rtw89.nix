# Steam Frame dongle fixes from ValveSoftware/SteamVR-for-Linux#965.
{ config, pkgs, ... }:
let
  kp = config.boot.kernelPackages;
  kernel = kp.kernel;

  # rtw89 with reg6_pwr_override (Davenport-Physics/rtw89-steam-frame) and debugfs.
  rtw89 = pkgs.stdenv.mkDerivation {
    pname = "rtw89-steam-frame";
    inherit (kernel) version src;
    nativeBuildInputs = kernel.moduleBuildDependencies;
    unpackPhase = ''
      tar -xf $src --wildcards '*/drivers/net/wireless/realtek/rtw89/*'
      cd */drivers/net/wireless/realtek/rtw89
    '';
    patches = [ ./rtw89-reg6-pwr-override.patch ];
    makeFlags = kp.kernelModuleMakeFlags ++ [
      "-C" "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      "CONFIG_RTW89_DEBUG=y" "CONFIG_RTW89_DEBUGFS=y"
      "KCFLAGS=-DCONFIG_RTW89_DEBUGFS=1"
    ];
    preBuild = "makeFlagsArray+=(M=$PWD)";
    buildFlags = [ "modules" ];
    installPhase = "install -Dm444 -t $out/lib/modules/${kernel.modDirVersion}/updates/rtw89 *.ko";
  };

  edca = "003f3219"; # TXOP 2000 us, CWmax 7, CWmin 3, AIFSN 1
in
{
  boot.extraModulePackages = [ rtw89 ];
  boot.extraModprobeConfig = "options rtw89_core reg6_pwr_override=1"; # LPI

  networking.networkmanager.wifi.powersave = false;

  # SteamOS's low latency mode; registers get reset mid-session, so recheck.
  systemd.services.steam-frame-low-latency = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.iw pkgs.gnugrep pkgs.coreutils ];
    serviceConfig.Restart = "always";
    script = ''
      while sleep 5; do
        iface=
        for d in /sys/class/net/*; do
          if [ "$(cat $d/device/../idVendor 2>/dev/null)" = 28de ] &&
             [ "$(cat $d/device/../idProduct 2>/dev/null)" = 2432 ]; then
            iface=''${d##*/}; break
          fi
        done
        [ -n "$iface" ] || continue
        dbg=/sys/kernel/debug/ieee80211/$(cat /sys/class/net/$iface/phy80211/name)/rtw89
        [ -d "$dbg" ] || continue

        if ! iw dev "$iface" station dump | grep -q '^Station'; then
          # HW_SCAN off blocks scans, so the headset could never be found again.
          grep -q '^Disabled DM: 0x0$' $dbg/disable_dm || echo 0 > $dbg/disable_dm
          continue
        fi

        grep -q 'at 0x0000c300=' $dbg/read_reg || echo 'c300 4' > $dbg/read_reg
        grep -q '=0x${edca}$' $dbg/read_reg && continue

        echo 0x30 > $dbg/disable_dm # HW_SCAN, INACTIVE_PS off
        iw dev "$iface" set power_save off
        iw dev "$iface" set tidconf tids 0xff amsdu off
        for r in c300 c304 c308 c30c; do echo "$r ${edca} 4" > $dbg/write_reg; done
        echo 'c610 107f3f3f 4' > $dbg/write_reg # 512 us A-MPDU airtime
        echo 'c62c 06060000 4' > $dbg/write_reg # 6 retries
        echo "low latency mode applied on $iface"
      done
    '';
  };
}
