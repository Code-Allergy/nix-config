{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [virt-manager qemu];

  virtualisation = {
    docker.enable = true;
    libvirtd = {
      enable = true;
      qemu.ovmf.enable = true;
      qemu.ovmf.packages = [pkgs.OVMFFull];
      qemu.swtpm.enable = true;
    };
    spiceUSBRedirection.enable = true;
  };

  environment.etc = {
    "ovmf/edk2-x86_64-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
    };

    "ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
    };
  };
}
