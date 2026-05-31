{ ... }:
{
  imports = [ ./system.nix ];

  neer = {
    modules = {
      user.home = ./home.nix;
      system = {
        gaming.enable = true;
        virtualization.enable = true;
        bluetooth = {
          enable = true;
          powerOnBoot = false;
        };
      };
    };
  };
}
