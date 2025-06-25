# AMDGPU specific configuration
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    corectrl
    lact
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
}
