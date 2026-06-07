{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.neer.modules.gaming;
in {
  options.neer.modules.gaming = {
    enable = mkEnableOption "Enable gaming home-manager configuration";
    lutris.enable =
      mkEnableOption "Enable Lutris"
      // {
        default = cfg.enable;
      };
    bottles.enable =
      mkEnableOption "Enable Bottles"
      // {
        default = cfg.enable;
      };
    vinegar.enable =
      mkEnableOption "Enable Vinegar"
      // {
        default = cfg.enable;
      };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        # Steam tools
        steamcmd
        steamtinkerlaunch

        # Wine
        wineWow64Packages.waylandFull

        # Minecraft (JAVA) launcher
        (prismlauncher.override {
          additionalLibs = [
            bzip2
            openssl
            nss
            nspr
          ];
          jdks = [
            temurin-jre-bin
            temurin-jre-bin-25
            temurin-jre-bin-17
            temurin-jre-bin-8
          ];
        })

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
        ryubing

        # PS3 Emulator
        rpcs3

        # PS2 Emulator
        pcsx2

        # Retroarch for other emus
        retroarch # TODO mbedtls 2 insecure

        # Game save backup tool
        ludusavi

        # Heroic Games Launcher
        heroic
        gogdl
        # legendary-heroic

        # Osu!
        # inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.osu-lazer-bin
      ];

      # TEMP
      # xdg.configFile."openvr/openvrpaths.vrpath".text = ''
      #   {
      #     "config" :
      #     [
      #       "${config.xdg.dataHome}/Steam/config"
      #     ],
      #     "external_drivers" : null,
      #    ...
      # '';

      programs.mangohud = {
        enable = true;
      };
    }

    {
      services.flatpak.packages = mkIf cfg.lutris.enable ["net.lutris.Lutris"];
    }

    {
      services.flatpak.packages = mkIf cfg.bottles.enable ["com.usebottles.bottles"];
    }

    {
      services.flatpak.packages = mkIf cfg.vinegar.enable ["org.vinegarhq.Sober"];
    }
  ]);
}
