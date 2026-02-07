{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    clang
    mesa-demos
    kdiff3
    emacs
    perf
    tracy
    meson
    rustup
    wireshark
    gtkwave
    dtc
    gdb
    sbcl
    yj
    zig
    xdot
    valgrind
    poetry
    sloc
    qemu
    picocom
    perf-tools
    iaito
    hyperfine
    flamegraph
    docker
    docker-compose
    docker-credential-helpers
    ccache
    cmake
    vscode-fhs
    ninja
    via
  ];
  programs.wireshark.enable = true;
  virtualisation = {
    docker = {
        enable = true;                # Enable Docker
        # enableNvidia = true;        # Enable Nvidia container runtime
    };
    lxc = {
        enable = true;
    	lxcfs = {
	  enable = true;
	};
    };
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };
  };
  programs.virt-manager.enable = true;
  programs.ccache.enable = true;
  hardware.rtl-sdr.enable = true;
  services.udev.packages = [ pkgs.qmk-udev-rules pkgs.rtl-sdr pkgs.via ];
}
