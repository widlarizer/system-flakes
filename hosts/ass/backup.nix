{ pkgs, ... }:
{
  systemd.services.backup-to-nas = {
    path = [ pkgs.bash pkgs.rsync pkgs.openssh ];
    serviceConfig.Type = "oneshot";
    script = ''
      timeout 20 bash -c '</dev/tcp/nas.tail3764a7.ts.net/22'
      systemctl stop home-assistant matterjs-server
      trap 'systemctl start matterjs-server home-assistant' EXIT
      rsync -a --delete \
        -e "ssh -i /root/.ssh/backup-nas -o StrictHostKeyChecking=accept-new -o ConnectTimeout=20" \
        /var/lib/hass /var/lib/private/matterjs-server \
        backup-ass@nas.tail3764a7.ts.net:
    '';
  };

  systemd.timers.backup-to-nas = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "03:15";
  };
}
