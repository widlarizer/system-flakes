{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
  services.plex = {
    enable = true;
    openFirewall = true;
    user = "emil";
    group = "users";
  };
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "emil";
    group = "users";
  };
}
