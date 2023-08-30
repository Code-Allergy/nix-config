{
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };

    libvirtd = {
      enable = true;
      qemu.ovmf.enable = true;
    };


    spiceUSBRedirection.enable = true;
    
  };

  # required for podman
  programs.dconf.enable = true;
}