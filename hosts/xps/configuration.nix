# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  services.earlyoom.enable = true;

  networking.hostName = "emil-xps15"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.networkmanager.wifi.powersave = true;

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
  services.resolved.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.emil = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDDh6uAcJQ8FrjBFny78/Q8hQVphP76DO9qXgZaXKRh/MGxhQ+jff/KZSzOmOIY1FHTCeL5sr5bWvMMPj7i7qyg+DRyvzD9BCXjqIFDcTH/GTvfQjpzGpMkZzDS3blEGhhDK97831C1hAoO1Kaot2MraOnUul6f6g7i3smmacqfiD54gZM6AXwTFoMZbVGJGI1XlCmBNnqTwmAJoAtlvMmiz8vsw+QPfhUhhIrqyIxVceaNinWDtPxzavJHLPBr1dNDFvt8hiHVOS17OhbUo10JHS7VyF4MbOXi/3QmF/rcqJ5QRJM8AdEecN112Y0qJt7xrqE9h0k78cpYNbAZy9KLCpHlWIWsJZqsoGEOF5beE22cRfIKFjFaDPaEL0fBevvU73xTvntHcU+gt9i6/CM5ylFRUkXXs2FG51ixBJC9Ydzp7MFVwz1BKv0XEuD2QfG/jHnZEUemvkCiksAj2L+T0uxy73V7vfFkSfpQ7HBsO4roZbT76N87BoV05gYSr2E= emil@fridge"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrjIuWPkLwHDdJqVkiUs9GZ2nNf3o6iGK+VOTUKGXth0GYK8tOUAXXeBC7OjpCw7iPhWkJwkFZibQcG/OWa/dMiZ7/Ky8s/jBqczKn4Ry9STVJSQN7IJOZmaMRKPYxafM+1iOtAabkb3y9pMdmQiQfkQ49v8thbL0YSnPR36R8s/WZFIWiytvJUmQxJjBwaEdbmLEZS/f9uhLgZeBXguCSstS909PkxzcuPCAl8M35tLdgF8TUg1hmJFRQzV9QK5bcOLY4cN4mGdJ+enEaY7n61di4RgfV1wCb154JbynDsKGvr9haVa5VVH5qeIuUJLymKUUPvlCZ8Dgsd4seMpuuvA8V2ixM1v9qMVwybWagHKdF90TuiAjzNXiAap5FgRuFX8tAjDGCHofuyxpH2yelgufjc1HOEZoO+RDpHEyUOpPR/hGKAAipB8Uvvyhdrx3l0VTK7S174JrEveGNJZ0+BBs7o7gmmzpMoSMpFt0ybjfYSa3qsU69H9lkiYw/CWk= emil@blahaj"
    ];
    packages = with pkgs; [
    ];
  };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    neovim
    wget
    alacritty
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "yes";
    openFirewall = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

  nixpkgs.config.allowUnfree = true;

}

