{ ... }:
{
  # imports = [ ./system.nix ];

  # Host-local home-manager overrides for `hihppo`.
  neer = {
    modules = {
      user.home = ./home.nix;
      system = {
        wsl2.enable = true;
        # gaming.enable = true;
        # virtualization.enable = true;
        # bluetooth.enable = true;
        # amdgpu.enable = true;
      };
    };
  };
}
