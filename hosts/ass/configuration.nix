{ config, pkgs, lib, ... }:
let
  haDir = config.services.home-assistant.configDir;
in
{
  # Fujitsu Futro S940 (Pentium Silver J5005, 4 GB RAM, 32 GB SATA SSD).
  # Headless Home Assistant box. SSH, tailscale, avahi, upgrades: modules/server.nix
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.enableRedistributableFirmware = true;

  networking.hostName = "ass";
  networking.useDHCP = true;

  # emil has no password, so sudo can't prompt for one
  security.sudo.wheelNeedsPassword = false;

  networking.firewall.allowedTCPPorts = [ 8123 ];
  services.home-assistant = {
    enable = true;
    extraComponents = [
      # needed to finish onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # faster zlib for aiohttp
      "isal"
      "esphome"
      "cast"
    ];
    config = {
      default_config = { };
      # let the UI editors save automations, scenes and scripts
      "automation ui" = "!include automations.yaml";
      "scene ui" = "!include scenes.yaml";
      "script ui" = "!include scripts.yaml";
    };
  };
  systemd.tmpfiles.rules = [
    "f ${haDir}/automations.yaml 0644 hass hass - []"
    "f ${haDir}/scenes.yaml 0644 hass hass - []"
    "f ${haDir}/scripts.yaml 0644 hass hass - {}"
  ];

  # Small SSD, low RAM
  zramSwap.enable = true;
  services.fstrim.enable = true;
  services.journald.settings.Journal.SystemMaxUse = "200M";
  documentation.nixos.enable = false;
  nix.settings.auto-optimise-store = true;

  environment.systemPackages = with pkgs; [ neovim htop git usbutils pciutils ];

  system.stateVersion = "26.11";
}
