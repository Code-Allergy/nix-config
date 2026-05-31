{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.neer.modules.system.amdgpu;
in
{
  options.neer.modules.system.amdgpu = {
    enable = mkEnableOption "amdgpu hardware";
  };
  config = mkIf cfg.enable {
    # AMDGPU specific configuration
    environment.systemPackages = with pkgs; [
      corectrl
      lact
      radeontop
      libva-utils
      vulkan-tools
    ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.amdgpu.opencl.enable = true;

    # support for ROCm on Nix
    systemd.tmpfiles.rules =
      let
        rocmEnv = pkgs.symlinkJoin {
          name = "rocm-combined";
          paths = with pkgs.rocmPackages; [
            rocblas
            hipblas
            clr
          ];
        };
      in
      [
        "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
      ];

    systemd.packages = with pkgs; [ lact ];
    systemd.services.lactd.wantedBy = [ "multi-user.target" ];

    # early load amdgpu kernel module, for hidpi support during boot
    hardware.amdgpu.initrd.enable = true;
    # enable overclocking, feature mask: 0xfffd7fff (supposedly less chance of flickering)
    hardware.amdgpu.overdrive.enable = true;
    # hardware.amdgpu.overdrive.ppfeaturemask = "0xffffffff";

    environment.variables = {
      NIXOS_OZONE_WL = "1"; # Electron apps use Wayland
      CLUTTER_BACKEND = "wayland";
      LIBVA_DRIVER_NAME = "radeonsi"; # Force correct VAAPI driver for video decoding
    };
  };
}
