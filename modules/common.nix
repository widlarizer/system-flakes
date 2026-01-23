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
    dust
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
  users.users.emil.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDDh6uAcJQ8FrjBFny78/Q8hQVphP76DO9qXgZaXKRh/MGxhQ+jff/KZSzOmOIY1FHTCeL5sr5bWvMMPj7i7qyg+DRyvzD9BCXjqIFDcTH/GTvfQjpzGpMkZzDS3blEGhhDK97831C1hAoO1Kaot2MraOnUul6f6g7i3smmacqfiD54gZM6AXwTFoMZbVGJGI1XlCmBNnqTwmAJoAtlvMmiz8vsw+QPfhUhhIrqyIxVceaNinWDtPxzavJHLPBr1dNDFvt8hiHVOS17OhbUo10JHS7VyF4MbOXi/3QmF/rcqJ5QRJM8AdEecN112Y0qJt7xrqE9h0k78cpYNbAZy9KLCpHlWIWsJZqsoGEOF5beE22cRfIKFjFaDPaEL0fBevvU73xTvntHcU+gt9i6/CM5ylFRUkXXs2FG51ixBJC9Ydzp7MFVwz1BKv0XEuD2QfG/jHnZEUemvkCiksAj2L+T0uxy73V7vfFkSfpQ7HBsO4roZbT76N87BoV05gYSr2E= emil@fridge"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrjIuWPkLwHDdJqVkiUs9GZ2nNf3o6iGK+VOTUKGXth0GYK8tOUAXXeBC7OjpCw7iPhWkJwkFZibQcG/OWa/dMiZ7/Ky8s/jBqczKn4Ry9STVJSQN7IJOZmaMRKPYxafM+1iOtAabkb3y9pMdmQiQfkQ49v8thbL0YSnPR36R8s/WZFIWiytvJUmQxJjBwaEdbmLEZS/f9uhLgZeBXguCSstS909PkxzcuPCAl8M35tLdgF8TUg1hmJFRQzV9QK5bcOLY4cN4mGdJ+enEaY7n61di4RgfV1wCb154JbynDsKGvr9haVa5VVH5qeIuUJLymKUUPvlCZ8Dgsd4seMpuuvA8V2ixM1v9qMVwybWagHKdF90TuiAjzNXiAap5FgRuFX8tAjDGCHofuyxpH2yelgufjc1HOEZoO+RDpHEyUOpPR/hGKAAipB8Uvvyhdrx3l0VTK7S174JrEveGNJZ0+BBs7o7gmmzpMoSMpFt0ybjfYSa3qsU69H9lkiYw/CWk= emil@blahaj"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM5wYkDQNJsdEO74XLYXjYguGirqMRALtvMNULfG2g3v emil@emil-xps15"
    ];
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

  hardware.keyboard.qmk.enable = true;
}
