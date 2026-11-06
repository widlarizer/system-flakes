# Declarative layout for the 32 GB SATA SSD. Matches what's on disk, so
# disko only provides the mounts; it formats nothing unless you run disko
# or nixos-anywhere on purpose.
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/ata-DEM24-32GM41BC1DC-PC_B0011907110050153";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          # Keep the existing GPT labels instead of disko's "disk-main-*"
          label = "ESP";
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            extraArgs = [ "-n" "BOOT" ];
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          label = "root";
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            extraArgs = [ "-L" "nixos" ];
            mountpoint = "/";
          };
        };
      };
    };
  };
}
