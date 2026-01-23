{ config, pkgs, ... }: let
  # bash script to let dbus know about important env variables and
  # propagate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts  
  # some user services to make sure they have the correct environment variables
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };
  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      #gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };
in {
  environment.systemPackages = with pkgs; [
    gif-for-cli
    waypipe
    tidal-hifi
    brightnessctl
    chromium
    inxi
    strawberry
    qbittorrent
    vlc
    discord
    flameshot
    slack
    wine
    winetricks
    #wineWowPackages.waylandFull
    wineWowPackages.full
    pulseaudio
    zulip
    xdg-utils
    waybar
    wev
    wget
    wlr-randr
    obs-studio-plugins.wlrobs
    iosevka
    alacritty
    swaybg
    swayidle
    sweet-nova
    slurp
    pinta
    pdfarranger
    pavucontrol
    obs-studio
    networkmanager_dmenu
    dmenu-rs
    nemo-with-extensions
    libreoffice-still
    meld
    inkscape
    gnome-themes-extra
    gparted
    grim
    gimp-with-plugins
    feh
    evince
    dunst
    drawio
    wdisplays # tool to configure displays
    #dracula-theme # gtk theme
    #adwaita-icon-theme  # default gnome cursors
    #glib
    wayland
    dbus-sway-environment
    configure-gtk
    mold
    firefox
  ];

  services.pipewire.enable = true;
  services.gnome.gnome-keyring.enable = true;

  hardware.graphics.enable = true;
  services.xserver.enable = true; # I love lying
  services.xserver.displayManager.startx.enable = false;
  services.xserver.displayManager.lightdm.enable = false;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  programs.nm-applet.enable = true;
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      noto-fonts-emoji-blob-bin
      nerd-fonts.noto
      liberation_ttf
      fira-code
      fira-code-symbols
      dina-font
      proggyfonts
      roboto
      roboto-mono
      roboto-serif
      font-awesome
    ];
  };

  # --- From NixOS wiki sway article

  # xdg-desktop-portal works by exposing a series of D-Bus interfaces
  # known as portals under a well-known name
  # (org.freedesktop.portal.Desktop) and object path
  # (/org/freedesktop/portal/desktop).
  # The portal interfaces include APIs for file access, opening URIs,
  # printing and others.
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # enable sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock
      swaylock-effects
      swayidle
      wl-clipboard
      mako
      wofi
      wofi-emoji
      wofi-power-menu
    ];
  };
  programs.dconf.enable = true;

  # --- End

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint ];

  services.blueman.enable = true;

}
