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
  };

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

  boot.kernelParams = ["amdgpu.ppfeaturemask=0xffffffff"];
  boot.initrd.kernelModules = ["amdgpu"];
}
