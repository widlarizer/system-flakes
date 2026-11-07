{ pkgs, ... }:
let
  dir = "/var/backup/ass";
in
{
  users.groups.backup-ass = { };
  users.users.backup-ass = {
    isSystemUser = true;
    group = "backup-ass";
    home = dir;
    createHome = true;
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = [
      ''command="${pkgs.rrsync}/bin/rrsync ${dir}/current",restrict ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKT0jDm9/Ia1snDO23EgKUU/ndy8cM1zrX7O4Qkn0wrb root@ass backup''
    ];
  };

  systemd.tmpfiles.rules = [ "d ${dir}/current 0700 backup-ass backup-ass -" ];

  systemd.services.backup-ass-snapshot = {
    serviceConfig = {
      Type = "oneshot";
      User = "backup-ass";
      WorkingDirectory = dir;
    };
    script = ''
      today=$(date +%F)
      [ -e "$today" ] || cp -al current "$today"
      cutoff=$(date -d '14 days ago' +%F)
      for s in 20??-??-??; do
        if [ -d "$s" ] && [[ "$s" < "$cutoff" ]]; then
          rm -rf -- "$s"
        fi
      done
    '';
  };

  systemd.timers.backup-ass-snapshot = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "03:45";
  };
}
