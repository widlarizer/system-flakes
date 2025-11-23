{ config, pkgs, inputs, ... }:
let
in
{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix

  ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #boot.kernelModules = [ "nouveau" ];
  boot.kernelParams = [ "modprobe.blacklist=dvb_usb_rtl28xxu" ]; # blacklist this module
  boot.extraModprobeConfig = '' options bluetooth disable_ertm=1 '';
  boot.kernelPackages = pkgs.linuxPackages_latest;
  #boot.blacklistedKernelModules = [ "nvidia" "nvidia_uvm" "nvidia_drm" "nvidia_modeset" ];

  networking.hostName = "blahaj"; # Define your hostname.
  networking.networkmanager.enable = true;

  # TODO this might be rly wrong
  # networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];
  # networking.networkmanager.dns = "none";

  networking.enableIPv6 = false;
  #services.nscd.enable = false;
  services.syncthing = {
    enable = true;
    user = "emil";
    dataDir = "/home/emil/sync";
    configDir = "/home/emil/.config/syncthing";
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
    settings.gui = {
      user = "admin";
      password = "m9KCQaHn";
    };
  };
  fileSystems."/mnt/Blue" = {
    device = "/dev/sda1";  # Replace with the actual device name (e.g., sda1)
    fsType = "ntfs";       # Replace with the file system type if different
    options = ["defaults" "uid=193" "gid=193"];
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  users.users = let extraGroups = [ "wheel" "docker" "lxd" "libvirtd" "input" "plugdev" "adbusers" ];
  in {
    emil = {
      isNormalUser = true;
      inherit extraGroups;
    };
  };
  programs.chromium.defaultSearchProviderEnabled = false;

  system.stateVersion = "23.05";
}
