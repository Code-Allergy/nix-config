{
  config,
  pkgs,
  self,
  userConf,
  ...
}:
with self.lib;
let
  cfg = config.neer.modules.user;

  defaultExtraGroups = existsOrDefault "extraGroups" userConf [
    "input"
    "uinput"
    "audio"
    "docker"
    "games"
    "locate"
    "libvirtd"
    "networkmanager"
    "wheel"
    "video"
    "netdev"
    "k3s"
    "kvm"
    "render"
    "adbusers"
    "dialout"
    "plugdev"
  ];

  defaultHashedPassword = existsOrDefault "hashedPassword" userConf null;
  defaultInitialPassword = existsOrDefault "initialPassword" userConf "CHANGEME123!";
in
{
  options.neer.modules.user = {
    name = mkOption {
      type = types.str;
      default = userConf.userName;
      description = "User's account name.";
    };

    home = mkOption {
      type = with types; nullOr path;
      default = null;
      description = "Path to host-local home-manager overrides.";
    };

    extraGroups = mkOption {
      type = types.listOf types.str;
      default = defaultExtraGroups;
      description = "The user's auxiliary groups.";
    };

    hashedPassword = mkOption {
      type = with types; nullOr (passwdEntry str);
      default = defaultHashedPassword;
      description = ''
        Specifies the hashed password for the user.
      '';
    };

    initialPassword = mkOption {
      type = with types; nullOr str;
      default = defaultInitialPassword;
      description = "Initial password used when no hashed password is provided.";
    };
  };

  config = mkMerge [
    {
      users.groups = {
        input = { };
        uinput = { };
        games = { };
        locate = { };
        k3s = { };
      };

      home-manager.users."${userConf.userName}" = mkUserHome {
        inherit system userConf;
        config = cfg.home;
      };

      users = {
        users.${cfg.name} =
          with cfg;
          {
            inherit extraGroups;
            isNormalUser = true;
            name = "${userConf.userName}";
            home = "/home/${userConf.userName}";
            description = existsOrDefault "displayName" userConf cfg.name;
            shell = pkgs.fish;
            uid = 1000;
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE4N8Fiv6jdkPy8yMeE35HoFypjobZ2sq1I/G8iWui5T codeallergy@gmail.com"
            ];
          }
          // optionalAttrs (cfg.hashedPassword != null) {
            hashedPassword = cfg.hashedPassword;
          }
          // optionalAttrs (cfg.hashedPassword == null && cfg.initialPassword != null) {
            initialPassword = cfg.initialPassword;
          };

        mutableUsers = true;
      };

      nix.settings.trusted-users = [ cfg.name ];
    }

    # (mkIf true {
    #   home-manager.users.${cfg.name} = mkUserHome {
    #     userConf = userConf;
    #     username = cfg.name;
    #     configName = cfg.name;
    #     system = pkgs.stdenv.hostPlatform.system;
    #     extraModules = optional (cfg.home != null) (import cfg.home);
    #   };
    # })
  ];
}
