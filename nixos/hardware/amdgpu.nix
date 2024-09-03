# AMDGPU specific configuration
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    corectrl
    lact
  ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;

    # openCL ROCm 
    extraPackages = [ pkgs.rocm-opencl-icd ];
  };

  # support for ROCm on Nix
  systemd.tmpfiles.rules = let
    rocmEnv = pkgs.symlinkJoin {
      name = "rocm-combined";
      paths = with pkgs.rocmPackages; [
        rocblas
        hipblas
        clr
      ];
    };
  in [
    "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  ];

  systemd.packages = with pkgs; [lact];
  systemd.services.lactd.wantedBy = ["multi-user.target"];

  # AMDGPU overclocking support
  boot.kernelParams = ["amdgpu.ppfeaturemask=0xffffffff"];

  # early load amdgpu kernel module, for hidpi support during boot
  boot.initrd.kernelModules = ["amdgpu"];
}
