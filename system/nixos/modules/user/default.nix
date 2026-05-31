{
  config,
  lib,
  pkgs,
  userConf,
  ...
}:
let
  cfg = config.neer.modules.user;

  isPasswdCompatible = str: !(lib.hasInfix ":" str || lib.hasInfix "\n" str);
  passwdEntry =
    type:
    lib.types.addCheck type isPasswdCompatible
    // {
      name = "passwdEntry ${type.name}";
      description = "${type.description}, not containing newlines or colons";
    };

  defaultExtraGroups = [
    "plugdev"
    "networkmanager"
    "wheel"
    "podman"
    "docker"
    "libvirtd"
    "audio"
    "video"
    "render"
    "kvm"
    "adbusers"
    "dialout"
  ];
in
{
  options.neer.modules.user = {
    name = lib.mkOption {
      type = lib.types.str;
      default = userConf.userName;
      description = "User's account name.";
    };

    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = defaultExtraGroups;
      description = "The user's auxiliary groups.";
    };

    hashedPassword = lib.mkOption {
      type = with lib.types; nullOr (passwdEntry str);
      default = lib.attrByPath [ "hashedPassword" ] null userConf;
      description = ''
        Specifies the hashed password for the user.
      '';
    };

    initialPassword = lib.mkOption {
      type = with lib.types; nullOr str;
      default = lib.attrByPath [ "initialPassword" ] "CHANGEME123!" userConf;
      description = "Initial password used when no hashed password is provided.";
    };
  };

  config = {
    users.groups.uinput = { };

    users.users.${cfg.name} = {
      isNormalUser = true;
      description = userConf.displayName or cfg.name;
      extraGroups = cfg.extraGroups;
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE4N8Fiv6jdkPy8yMeE35HoFypjobZ2sq1I/G8iWui5T codeallergy@gmail.com"
      ];
    }
    // lib.optionalAttrs (cfg.hashedPassword != null) {
      hashedPassword = cfg.hashedPassword;
    }
    // lib.optionalAttrs (cfg.hashedPassword == null && cfg.initialPassword != null) {
      initialPassword = cfg.initialPassword;
    };

    nix.settings.trusted-users = [ cfg.name ];
  };
}
