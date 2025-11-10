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
    neofetch
    nmap
    moreutils
    htop
    bottom
    git
    du-dust
    croc
    p7zip
    bat
    any-nix-shell
    wget
    fish
  ];
  programs.direnv.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  users.defaultUserShell = pkgs.fish;
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
}