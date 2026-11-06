# Imported from nas:/etc/nixos/configuration.nix. SSH, tailscale, avahi base,
# timezone, gc and nightly upgrades come from modules/server.nix.
{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.gc.options = "--delete-older-than 30d";

  networking.hostName = "nas";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];
  networking.enableIPv6 = false;
  networking.networkmanager.dns = "none";
  systemd.services.NetworkManager-wait-online.enable = false;

  services.avahi.publish = {
    domain = true;
    hinfo = true;
    userServices = true;
    workstation = true;
  };

  services.locate.package = pkgs.mlocate;
  services.locate.enable = true;
  services.plex = {
    enable = true;
    openFirewall = true;
    user = "plex";
    group = "plex";
  };
  services.immich = {
    enable = true;
    package = pkgs.immich;
    port = 2283;
    openFirewall = true;
    host = "0.0.0.0";
  };

  hardware.graphics.enable = true;

  users.users.emil = {
    extraGroups = [ "docker" "input" ];
    packages = with pkgs; [ bottom ];
    shell = pkgs.fish;
    # Keys that were only on nas, kept so nothing loses access
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8Oq/UGbGCfca03Y6HTbMZKFxTfohEsdsksvlrNZhCA3Co0UnSu9I89X96D/3CJEGSMRLNyNDCHc1B8jEv7eHplXzP5MIjskC+RpHcFdCrHZYmR+CSP4y6lDF19i2uS/DovEdTEQ3GRN/gpWUULzH8IOCpOk4EOKgYy/wElMhUyNBhUlDVYCVqtFOT34QoAfEHYiTeA/FCly+/uh97WGrdlDQ7QEyxug0fUGBmIWpsGgSUW8HcuhKjU6FQ3GOIRQERlO6/nXyfVqqtWnfrj2CAMRZXi1Vu1jm4MOT4Q8prXqc2hNXqaEuW5TONR3xQqKbpH1UH3ggMhHgiA8PATpH80BqyKBtFeih55Hx59twgZKAf/4lsSvTjIkqdZk64TVHpoN1MiL4UOsu5ZaQFEW2WOIxyjitZKOfRJZp8olGrokP+a7E7Y7PDQ0Jz/YJDMOmgYIw/ge5lqU1uagVG/C93uk0u2h3xUNsCP1PD5Togr9XTVtKCoxqmym9U+1ZqEh8= emil@emil-xps15"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHHkEc/134ebAuhLeNGfNPc03HHN9QRNlRNqA7uV6W+"
    ];
  };

  # nas has always allowed password logins over SSH
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.KbdInteractiveAuthentication = true;

  networking.firewall.allowedTCPPorts = [
    3923
    # mediamtx
    8554
    1935
    8888
    8889
  ];
  networking.firewall.allowedUDPPorts = [
    # mediamtx
    8890
    8189
  ];
  networking.firewall.enable = false;

  # Don't change: decides on-disk formats (e.g. the postgres version immich uses)
  system.stateVersion = "23.11";

  environment.systemPackages = with pkgs; [
    p7zip
    wget
    neovim
    any-nix-shell
  ];
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  services.dbus.enable = true;

  programs.fish.enable = true;
  programs.fish.promptInit = ''
    any-nix-shell fish --info-right | source
  '';
  programs.git.enable = true;
}
