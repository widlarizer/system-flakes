{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    scdl
    ardour
    audacity
    infamousPlugins
    ladspaPlugins
    adlplug
    mixxx
    nicotine-plus
  ];
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
