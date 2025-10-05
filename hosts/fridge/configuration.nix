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

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
  };

  services.vscode-server.enable = true;
  services.nixseparatedebuginfod.enable = true;

  #systemd.services."rerouter" = {
  #  enable = true;
  #  description = "Open reverse SSH tunnel to rerouter";
  #  unitConfig.Type = "simple";
  #  after = [ "network.target" ];
  #  serviceConfig = {
  #    ExecStart = "${pkgs.openssh}/bin/ssh -vvv -N -R 2222:localhost:22 root@167.71.62.54";
  #    Restart = "always";
  #    RestartSec = "5s";
  #    User = "emil";
  #  };
  #  wantedBy = [ "multi-user.target" ];
  #};
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "yes";
  };

# Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  services.earlyoom.enable = true;

  networking.hostName = "fridge"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  #networking.interfaces.enp13s0.wakeOnLan.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  services.avahi = {
    nssmdns4 = true;
    nssmdns6 = true;
    enable = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
  services.resolved = { enable = true; };

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
  #services.immich.enable = true;
  #services.immich.port = 2283;
  #services.immich.accelerationDevices = null;

  # Enable CUPS to print documents.
  #services.printing.enable = true;
  #services.printing.drivers = [ pkgs.cnijfilter2 pkgs.gutenprint ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.fish;
  users.users = let extraGroups = [ "wheel" "docker" "lxd" "libvirtd" ];
  in {
    emil = {
      isNormalUser = true;
      inherit extraGroups;
      packages = with pkgs; [ firefox alacritty stress wireshark ];
    };
  };
  services.gnome.gnome-keyring.enable = true;
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "nofile";
      value = "9192";
    }
  ];
  #security.pki.certificates = [ "foo" ];
  services.xserver.enable = true; # I love lying
  services.xserver.videoDrivers = [ "mesa" ];
  services.xserver.displayManager.startx.enable = false;
  services.xserver.displayManager.lightdm.enable = false;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  programs.nix-ld.enable = true;
  programs.fish.enable = true;
  programs.nm-applet.enable = true;
  programs.wireshark.enable = true;
  virtualisation = {
    docker = {
        enable = true;                # Enable Docker
        # enableNvidia = true;        # Enable Nvidia container runtime
    };
    lxc = {
        enable = true;
    	lxcfs = {
	  enable = true;
	};
    };
    libvirtd = {
      enable = true;
    };
  };
  programs.virt-manager.enable = true;
  programs.ccache.enable = true;
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    noto-fonts-emoji-blob-bin
    nerd-fonts.noto
    liberation_ttf
    fira-code
    fira-code-symbols
    dina-font
    proggyfonts
    roboto
    roboto-mono
    roboto-serif
    font-awesome
  ];
#  services.minecraft = {
#    enable = true;
#    eula = true;
#    openFirewall = true;
#    jvmOpts = "-Xms16G -Xmx16G -XX:NmethodSweepActivity=1 -XX:ReservedCodeCacheSize=400M -XX:NonNMethodCodeHeapSize=12M -XX:ProfiledCodeHeapSize=194M -XX:NonProfiledCodeHeapSize=194M"
#      + "-XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+AlwaysActAsServerClassMachine -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:NmethodSweepActivity=1 -XX:ReservedCodeCacheSize=400M -XX:NonNMethodCodeHeapSize=12M -XX:ProfiledCodeHeapSize=194M -XX:NonProfiledCodeHeapSize=194M -XX:-DontCompileHugeMethods -XX:MaxNodeLimit=240000 -XX:NodeLimitFudgeFactor=8000 -XX:+UseVectorCmov -XX:+PerfDisableSharedMem -XX:+UseFastUnorderedTimeStamps -XX:+UseCriticalJavaThreadPriority -XX:ThreadPriorityPolicy=1"
#      + "-XX:+UseG1GC -XX:MaxGCPauseMillis=130 -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=28 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=20 -XX:G1MixedGCCountTarget=3 -XX:InitiatingHeapOccupancyPercent=10 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=0 -XX:SurvivorRatio=32 -XX:MaxTenuringThreshold=1 -XX:G1SATBBufferEnqueueingThresholdPercent=30 -XX:G1ConcMarkStepDurationMillis=5.0 -XX:G1ConcRefinementServiceIntervalMillis=150 -XX:G1ConcRSHotCardLimit=16 -XX:AllocatePrefetchStyle=3";
#  };
hardware.graphics = {
  enable32Bit = true;
  extraPackages = [ pkgs.intel-media-driver pkgs.vpl-gpu-rt ];
};
  #hardware.xpadneo.enable = true;
  hardware.bluetooth.enable = true;
  hardware.opentabletdriver.enable = true;

  #networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 22 80 443 8080 25565  ];
  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;
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

  # From NixOS wiki sway article

  # xdg-desktop-portal works by exposing a series of D-Bus interfaces
  # known as portals under a well-known name
  # (org.freedesktop.portal.Desktop) and object path
  # (/org/freedesktop/portal/desktop).
  # The portal interfaces include APIs for file access, opening URIs,
  # printing and others.
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # enable sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  # End

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };
  security.polkit.enable = true;
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
  nix.extraOptions = "experimental-features = nix-command flakes";
  nixpkgs.config.allowUnfree = true;
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
