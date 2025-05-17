{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.global.config.gaming;
  headed = config.global.config.headless == false;
in
{
  options.global.config.gaming = {
    enable = mkEnableOption "Enable gaming home-manager configuration";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      mkIf headed [
        # Steam tools
        steamcmd
        steamtinkerlaunch

        # Wine
        wineWowPackages.waylandFull

        # Minecraft (JAVA) launcher
        prismlauncher

        # Minecraft (BEDROCK) launcher
        mcpelauncher-client
        mcpelauncher-ui-qt

        # Minecraft ComputerCraft Emulator
        ccemux

        # Wii/Gamecube Emulator
        dolphin-emu

        # Wii U Emulator
        cemu

        # Switch Emulator
        ryujinx

        # PS3 Emulator
        rpcs3

        # PS2 Emulator
        pcsx2

        # Retroarch for other emus
        retroarch

        # Game save backup tool
        ludusavi

        # Heroic Games Launcher
        heroic
        gogdl
        legendary-heroic
      ];

    # TEMP
    # xdg.configFile."openvr/openvrpaths.vrpath".text = ''
    #   {
    #     "config" :
    #     [
    #       "${config.xdg.dataHome}/Steam/config"
    #     ],
    #     "external_drivers" : null,
    #     "jsonid" : "vrpathreg",
    #     "log" :
    #     [
    #       "${config.xdg.dataHome}/Steam/logs"
    #     ],
    #     "runtime" :
    #     [
    #       "${pkgs.opencomposite}/lib/opencomposite"
    #     ],
    #     "version" : 1
    #   }
    # '';
    # xdg.configFile."openxr/1/active_runtime.json".source =
    #   "${pkgs.monado}/share/openxr/1/openxr_monado.json";

    programs.mangohud = {
      enable = true;
    };
  };
}
