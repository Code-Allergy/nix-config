{
  pkgs,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    podman-compose
    virtio-win
    bridge-utils

    # winapps
    inputs.winapps.packages."${system}".winapps
    inputs.winapps.packages."${system}".winapps-launcher
  ];

  programs.virt-manager.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
          ];
        };
      };
    };
    waydroid.enable = true;
    spiceUSBRedirection.enable = true;
  };

  # environment.etc = {
  #   "ovmf/edk2-x86_64-secure-code.fd" = {
  #     source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
  #   };

  #   "ovmf/edk2-i386-vars.fd" = {
  #     source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
  #   };
  # };
}
