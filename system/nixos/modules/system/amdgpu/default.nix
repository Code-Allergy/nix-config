{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.neer.modules.system.amdgpu;
in {
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
    # systemd.tmpfiles.rules = let
    #   rocmEnv = pkgs.symlinkJoin {
    #     name = "rocm-combined";
    #     paths = with pkgs.rocmPackages; [
    #       rocblas
    #       hipblas
    #       clr
    #     ];
    #   };
    # in [
    #   "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
    # ];

    systemd.packages = with pkgs; [lact];
    systemd.services.lactd.wantedBy = ["multi-user.target"];
    hardware.amdgpu.initrd.enable = true;
    hardware.amdgpu.overdrive.enable = true;

    security = {
      # CoreCtrl Configuration
      polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if ((action.id == "org.corectrl.helper.init" ||
              action.id == "org.corectrl.helperkiller.init") &&
              subject.local == true &&
              subject.active == true &&
              subject.isInGroup("users")) {
                  return polkit.Result.YES;
              }
        });
      '';
      # Other security options: https://nixos.org/nixos/options.html#security
    };

    environment.variables = {
      NIXOS_OZONE_WL = "1"; # Electron apps use Wayland
      CLUTTER_BACKEND = "wayland";
      LIBVA_DRIVER_NAME = "radeonsi"; # Force correct VAAPI driver for video decoding
    };
  };
}
