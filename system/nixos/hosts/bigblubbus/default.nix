{ ... }:
{
  imports = [ ./system.nix ];

  # Host-local home-manager overrides for `bigblubbus`.
  # TODO: move program selection to a higher-level profile and keep this as
  # local overrides only.
  neer = {
    modules = {
      user.home = ./home.nix;
      system = {
        gaming.enable = true;
        virtualization.enable = true;
        bluetooth.enable = true;
        amdgpu.enable = true;
        tailscale.enable = true;
        footpedal.enable = true;
      };
    };
    profiles.desktop.enable = true;
  };
}
