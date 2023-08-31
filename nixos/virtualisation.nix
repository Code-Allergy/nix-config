{ pkgs, ... }:

{
  
  environment.systemPackages = with pkgs; [ virt-manager ];

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };

    libvirtd = {
      enable = true;
      qemu.ovmf.enable = true;
      qemu.swtpm.enable = true;
    };
    spiceUSBRedirection.enable = true;

    oci-containers.containers = {
      # tdarr_node = {
      #   image = "ghcr.io/haveagitgat/tdarr";
      #   volumes = [
      #     "/etc/tdarr:/app/configs"
      #     "/var/log/tdarr:/app/logs"
      #     "/mnt/media:/media"
      #     "/mnt/ingest/Tcache:/temp"
      #   ];
      #   environment = {
      #     nodeName = "blubbus";
      #     serverIP = "192.168.1.112";
      #     serverPort = "8266";
      #     inContainer = "true";
      #     TZ = "America/Regina";
      #     PUID = "1000";
      #     PGID = "1000";
      #     NVIDIA_DRIVER_CAPABILITIES = "all";
      #     NVIDIA_VISIBLE_DEVICES = "all";
      #   };
      #   extraOptions = [
      #     "--gpus=all" "--device=/dev/dri:/dev/dri"
      #     "--network=bridge"
      #   ];
      # };


    };
  };

  # required for podman
  programs.dconf.enable = true;
}