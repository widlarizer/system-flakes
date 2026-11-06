# Shared by the headless boxes (ass, nas).
{ lib, ... }:
let
  keys = import ./ssh-keys.nix;
in
{
  users.users.root.openssh.authorizedKeys.keys = keys;
  users.users.emil = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = keys;
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
    settings.PasswordAuthentication = lib.mkDefault false;
    settings.KbdInteractiveAuthentication = lib.mkDefault false;
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # <hostname>.local on the LAN
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  time.timeZone = "Europe/Prague";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = lib.mkDefault "--delete-older-than 14d";
  };

  # Every night, rebuild from the repo on GitHub (picks nixosConfigurations.<hostname>)
  # with the newest nixpkgs, without needing flake.lock bumps. Only pushed commits count.
  # Deploying by hand from an older checkout would downgrade packages, so run
  # `nix flake update nixpkgs` first.
  system.autoUpgrade = {
    enable = true;
    flake = "github:widlarizer/system-flakes";
    flags = [ "--update-input" "nixpkgs" "-L" ];
    upgrade = false;
    dates = "04:00";
    randomizedDelaySec = "45min";
  };
}
