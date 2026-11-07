{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    neovim
    tealdeer
    thermald
    traceroute
    file
    tree
    libqalculate
    xarchiver
    fd
    direnv
    nix-direnv
    usbutils
    unzip
    pv
    eza
    nixpkgs-fmt
    pciutils
    polkit_gnome
    ffmpeg
    stress
    plocate
    pbzip2
    pass
    fastfetch
    nmap
    moreutils
    htop
    bottom
    git
    dust
    croc
    p7zip
    bat
    any-nix-shell
    wget
    fish
    qmk
    via
  ];
  programs.direnv.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  users.defaultUserShell = pkgs.fish;
  users.users.emil.openssh.authorizedKeys.keys = import ./ssh-keys.nix;
  programs.fish.enable = true;
  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;

  security.polkit.enable = true;
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "nofile";
      value = "9192";
    }
  ];

  time.timeZone = "Europe/Prague";

  services.avahi = {
    nssmdns4 = true;
    enable = true;
    settings.publish = {
      disable-publishing = false;
      publish-addresses = true;
      publish-workstation = true;
    };
    openFirewall = true;
  };
  services.resolved = { enable = true; };
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "yes";
  };


  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
  };
  nix.extraOptions = "experimental-features = nix-command flakes";
  nixpkgs.config.allowUnfree = true;

  hardware.keyboard.qmk.enable = true;
  services.udev.packages = [ pkgs.via ];
  services.udisks2.enable = true;
}
