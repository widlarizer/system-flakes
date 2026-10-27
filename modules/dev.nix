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
    sublime-merge
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
  # Disabled: its nix-ccache setgid wrapper is a perl script, which nixpkgs'
  # ensure-wrapper-integrity check now rejects (non-ELF). Re-enable once fixed upstream.
  # programs.ccache.enable = true;
  hardware.rtl-sdr.enable = true;
  services.udev.packages = [ pkgs.rtl-sdr ];
}
