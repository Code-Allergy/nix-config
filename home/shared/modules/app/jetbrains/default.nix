{lib, ...}:
with lib; {
  imports = [
    ./idea.nix
    ./pycharm.nix
    ./webstorm.nix
    ./clion.nix
    ./rust-rover.nix
    ./rider.nix
    ./android-studio.nix
  ];

  options.neer.modules.app.jetbrains = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Master switch for JetBrains IDEs. Individual product modules inherit this when their own enable option is unset.";
    };

    remote.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable JetBrains Remote support.";
    };
  };
}
