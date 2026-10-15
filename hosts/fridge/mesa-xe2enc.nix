# Steam Frame streaming on Intel Arc B-series (Xe2, e.g. B580): Mesa with
# H.265 Vulkan Video encode, plus the Steam settings vrlink needs.
#
# Only useful on Arc B-series; it replaces the system Mesa.
#
# To use, add the Mesa branch as a flake input and import this file:
#
#   inputs.mesa-xe2enc = {
#     url = "github:widlarizer/mesa/anv-xe2-video-encode";
#     flake = false;
#   };
#
# The flake has to pass `inputs` to modules (specialArgs = { inherit inputs; }).
# Pick up new commits with `nix flake update mesa-xe2enc`.
#
# The overrides below adapt nixpkgs' Mesa 26.2 recipe (nixos-unstable,
# October 2026) to the Mesa main tree; other nixpkgs revisions may need
# adjustments.
{ lib, pkgs, inputs, ... }:
let
  # Mesa main needs this subproject for its virtio-based drivers; meson can't
  # download it in the sandbox.
  venus-protocol = pkgs.fetchzip {
    url = "https://gitlab.freedesktop.org/virgl/venus-protocol/-/archive/v1.1.3/venus-protocol-v1.1.3.tar.gz";
    sha256 = "04qmq47q9flbp98llbgz62ivhnycmgp8xzis0kcb20cbmgdrp53s";
  };

  # nixpkgs' opencl.patch, rebased onto Mesa main.
  opencl-patch = pkgs.writeText "mesa-opencl-main.patch" ''
    diff --git a/meson.build b/meson.build
    --- a/meson.build
    +++ b/meson.build
    @@ -2098,7 +2098,7 @@ endif
     
     dep_clang = null_dep
     if with_clc
    -  llvm_libdir = dep_llvm.get_variable(cmake : 'LLVM_LIBRARY_DIR', configtool: 'libdir')
    +  llvm_libdir = get_option('clang-libdir')
     
       dep_clang = cpp.find_library('clang-cpp', dirs : llvm_libdir, required : false)
     
    diff --git a/meson.options b/meson.options
    --- a/meson.options
    +++ b/meson.options
    @@ -923,3 +923,10 @@ option(
       value : true,
       description : 'Build panfrost disassemblers. Explicitly setting this option to false will cause the panfrost stack to build without disassemblers. This should be left enabled for distro builds.'
     )
    +
    +option(
    +  'clang-libdir',
    +  type : 'string',
    +  value : ''',
    +  description : 'Locations to search for clang libraries.'
    +)
    diff --git a/src/gallium/targets/rusticl/meson.build b/src/gallium/targets/rusticl/meson.build
    --- a/src/gallium/targets/rusticl/meson.build
    +++ b/src/gallium/targets/rusticl/meson.build
    @@ -64,7 +64,7 @@ configure_file(
       configuration : _config,
       input : 'rusticl.icd.in',
       output : 'rusticl.icd',
    -  install : true,
    +  install : false,
       install_tag : 'runtime',
       install_dir : join_paths(get_option('sysconfdir'), 'OpenCL', 'vendors'),
     )
  '';

  mesa-xe2enc = (pkgs.mesa.override {
    # Mesa main dropped the anti-lag layer.
    vulkanLayers = [ "device-select" "intel-nullhw" "overlay" "screenshot" "vram-report-limit" ];
  }).overrideAttrs (old: {
    version = "26.3.0-devel-xe2enc";
    src = inputs.mesa-xe2enc;
    patches = [ opencl-patch ];
    postUnpack = (old.postUnpack or "") + ''
      cp -r ${venus-protocol} $sourceRoot/subprojects/venus-protocol-1.1.3
      chmod -R u+w $sourceRoot/subprojects/venus-protocol-1.1.3
    '';
  });
in
{
  # Only the 64-bit driver; 32-bit games keep the stock Mesa.
  hardware.graphics.package = mesa-xe2enc;

  # ANV keeps Vulkan Video behind ANV_DEBUG, enable it for Steam (and with it
  # SteamVR / vrlink) only. -pipewire makes Steam capture through PipeWire.
  # If you already set programs.steam.package, merge this into it.
  programs.steam.package = pkgs.steam.override (prev: {
    extraEnv = (prev.extraEnv or { }) // {
      ANV_DEBUG = "video-decode,video-encode";
    };
    extraArgs = lib.concatStringsSep " " (lib.filter (a: a != "") [
      (prev.extraArgs or "")
      "-pipewire"
    ]);
  });
}
