{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.neer.modules.services.ai-inference;
  cache = cfg.modelCache;
in
{
  options.neer.modules.services.ai-inference.modelCache = {
    enable = lib.mkEnableOption "an on-demand local model cache";

    sourceDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/ai-inference/model-catalog";
      description = "Large-capacity model catalog directory used as the cache source.";
    };

    directory = lib.mkOption {
      type = lib.types.str;
      default = "/var/cache/ai-inference/models";
      description = "Fast local directory used for cached model files.";
    };

    maxSizeGiB = lib.mkOption {
      type = lib.types.ints.positive;
      description = "Maximum model cache size in GiB before least-recently-used files are evicted.";
    };

    samba = {
      enable = lib.mkEnableOption "a read-only Samba model catalog";

      share = lib.mkOption {
        type = lib.types.str;
        example = "//10.10.10.10/AIModels";
        description = "UNC path of the Samba model catalog share.";
      };

      mountOptions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "_netdev"
          "noauto"
          "x-systemd.automount"
          "x-systemd.idle-timeout=10min"
          "x-systemd.mount-timeout=10s"
          "nofail"
          "ro"
          "guest"
          "vers=3.1.1"
          "uid=0"
          "gid=0"
          "file_mode=0444"
          "dir_mode=0555"
        ];
        description = "Options used to mount the model catalog share.";
      };
    };
  };

  config = lib.mkIf (cfg.enable && cache.enable) {
    assertions = [
      {
        assertion = cache.sourceDirectory != cache.directory;
        message = "ai-inference model cache sourceDirectory and directory must differ";
      }
    ];

    systemd.tmpfiles.rules = [
      "d ${cache.directory} 0750 root root -"
    ];

    environment.systemPackages = lib.optional cache.samba.enable pkgs.cifs-utils;

    fileSystems = lib.mkIf cache.samba.enable {
      ${cache.sourceDirectory} = {
        device = cache.samba.share;
        fsType = "cifs";
        options = cache.samba.mountOptions;
      };
    };
  };
}
