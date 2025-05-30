{lib, ...}: {
  networking = {
    hostName = "bigblubbus";
    useDHCP = lib.mkDefault true;
    networkmanager = {
      enable = true;
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
        8000 # Dev server
        22000 # Syncthing
      ];
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } # KDE Connect
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } # KDE Connect
      ];
    };
  };
}
