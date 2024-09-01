{pkgs, ...}: {
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  programs.gamemode.enable = true;
  programs.gamemode.settings = {
    gpu.apply_gpu_optimisations = "accept-responsibility";
    gpu.device = 1;
    custom = {
      start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
      end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
    };
  };

  # Still can't get gamescope to work. TODO
  # programs.gamescope.enable = true;
  # programs.gamescope.capSysNice = true;

  # nixpkgs.config.packageOverrides = pkgs: {
  #   steam = pkgs.steam.override {
  #     extraPkgs = pkgs:
  #       with pkgs; [
  #         xorg.libXcursor
  #         xorg.libXi
  #         xorg.libXinerama
  #         xorg.libXScrnSaver
  #         libpng
  #         libpulseaudio
  #         libvorbis
  #         stdenv.cc.cc.lib
  #         libkrb5
  #         keyutils
  #       ];
  #   };
  # };
}
