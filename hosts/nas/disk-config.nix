{
 disko.devices = {
  disk = {
   my-disk = {
    device = "/dev/nvme0n1";
    type = "disk";
    content = {
     type = "gpt";
     partitions = {
      ESP = {
       type = "EF00";
       size = "500M";
       content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
       };
      };
      root = {
       end = "-4G";
       content = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/";
       };
      };
      plainSwap = {
        size = "100%";
        content = {
          type = "swap";
 #         resumeDevice = true; # resume from hiberation from this device
        };
      };
     };
    };
   };
  };
 };
}
