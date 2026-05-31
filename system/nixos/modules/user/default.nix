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

      users.users.${cfg.name} = {
        isNormalUser = true;
        description = existsOrDefault "displayName" userConf cfg.name;
        extraGroups = cfg.extraGroups;
        shell = pkgs.fish;
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

      nix.settings.trusted-users = [ cfg.name ];
    }
  ];
}
