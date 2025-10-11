{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
  ];
  services.plex = {
    enable = true;
    openFirewall = true;
    user = "plex";
    group = "plex";
  };
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "plex";
    group = "plex";
  };
}
