{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    scdl
    ardour
    infamousPlugins
    ladspaPlugins
    adlplug
    mixxx
    nicotine-plus
  ];
}
