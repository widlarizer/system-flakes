# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, inputs, ... }:
let
in
{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # /home/emil/personal/wiki/mediawiki-temp.nix
    inputs.nixos-vscode-server.nixosModules.default

  ];

  fileSystems."/mnt/Blue" = {
    device = "/dev/disk/by-label/why";
    #fsType = "auto";
    #options = [ "nosuid" "nodev" "nofail" "x-gvfs-show"];
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1001"];
  };
  fileSystems."/mnt/s" = {
    device = "/dev/disk/by-label/s";
  };

  services.vscode-server.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  services.earlyoom.enable = true;

  networking.hostName = "fridge"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.interfaces.enp15s0.wakeOnLan.enable = true;

  services.syncthing = {
    enable = true;
    user = "emil";
    dataDir = "/mnt/Blue/sync";
    configDir = "/home/emil/.config/syncthing";
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
    settings.gui = {
      thisVariableDoesntExist = "yep";
      user = "admin";
      password = "m9KCQaHn";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = let extraGroups = [ "wheel" "docker" "lxd" "libvirtd" "input" ];
  in {
    emil = {
      isNormalUser = true;
      inherit extraGroups;
    };
  };

  services.xserver.videoDrivers = [ "mesa" ];
  hardware.graphics = {
    enable32Bit = true;
    extraPackages = [ pkgs.intel-media-driver pkgs.vpl-gpu-rt ];
  };

  #networking.firewall.enable = false;
  # networking.firewall.allowedTCPPorts = [ 22 80 443 8080 25565  ];
  #services.tailscale.useRoutingFeatures = "both";
  #services.tailscale.extraUpFlags = ["--login-server=http://warp.tywoniak.eu:8080" "--accept-dns=false" "--authkey" "8fb4bf60293a6cbd5a38048910f4df6820444df5e63ff583" "--accept-routes" "--advertise-exit-node" "--reset"];
#  systemd.services.tunnel = {
#    description = "Tailscale Exit Node Connection";
#    after = [ "network.target" "tailscale.service" ];
#    wantedBy = [ "multi-user.target" ];
#    serviceConfig = {
#      ExecStart = "${pkgs.tailscale}/bin/tailscale up --accept-routes --exit-node=vps-tailscale-id";
#      Type = "oneshot";
#      RemainAfterExit = true;
#    };
#  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
  nixpkgs.overlays = [
    (final: prev: {
      steam = prev.steam.override ({ extraLibraries ? pkgs': [], ... }: {
        extraLibraries = pkgs': (extraLibraries pkgs') ++ ( [
          pkgs'.gperftools
        ]);
      });
    })
  ];

}
