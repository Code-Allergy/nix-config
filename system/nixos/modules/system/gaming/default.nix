{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.neer.modules.system.gaming;
in
{
  options.neer.modules.system.gaming = {
    enable = mkEnableOption "Enable gaming configuration";
    steam = {
      enable = mkEnableOption "Enable Steam" // {
        default = cfg.enable;
      };
      gamescopeSession = {
        enable = mkEnableOption "Enable GameScope session" // {
          default = cfg.enable;
        };
      };
    };

    lutris = {
      enable = mkEnableOption "Enable Lutris" // {
        default = cfg.enable;
      };
    };

    gamemode = {
      enable = mkEnableOption "Enable Gamemode" // {
        default = cfg.enable;
      };
    };

    sunshine = {
      enable = mkEnableOption "Enable Sunshine" // {
        default = cfg.enable;
      };
      startup = mkEnableOption "Enable Sunshine to start on boot" // {
        default = false;
      };
    };
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = cfg.steam.enable;
      gamescopeSession.enable = cfg.steam.gamescopeSession.enable;

      remotePlay.openFirewall = cfg.steam.enable; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = cfg.steam.enable; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = cfg.steam.enable; # Open ports in the firewall for Steam Local Network Game Transfers
    };

    programs.gamescope = {
      enable = cfg.steam.enable;
      capSysNice = cfg.steam.enable;
    };

    programs.gamemode = {
      enable = cfg.gamemode.enable;
      settings = {
        gpu.apply_gpu_optimisations = "accept-responsibility";
        gpu.device = 1;
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };

    services.sunshine = {
      enable = cfg.sunshine.enable;
      autoStart = cfg.sunshine.startup;
      capSysAdmin = cfg.sunshine.enable;
      openFirewall = cfg.sunshine.enable;
    };

    # services.monado = {
    #   enable = cfg.steam.enable;
    #   defaultRuntime = cfg.steam.enable;
    # };

    # environment.systemPackages = with pkgs; [
    #   basalt-monado
    #   opencomposite
    # ];

    # systemd.user.services.monado.environment = {
    #   STEAMVR_LH_ENABLE = "1";
    #   XRT_COMPOSITOR_COMPUTE = "1";
    #   WMR_HANDTRACKING = "0";
    # };

  };
}
