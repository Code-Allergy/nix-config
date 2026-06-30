{...}: {
  # Host-local home-manager overrides for `bigblubbus`.
  imports = [./system.nix];

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
