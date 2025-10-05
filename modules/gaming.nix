{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    osu-lazer-bin
    prismlauncher
  ];
  programs.steam = {
    enable = true;
  };
}
