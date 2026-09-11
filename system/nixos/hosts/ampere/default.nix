{...}: {
  # Host-local home-manager overrides for `bigblubbus`.
  imports = [./system.nix];

  neer = {
    modules = {
      user.home = ./home.nix;
      system = {
        gaming.enable = false;
        virtualization.enable = true;
        bluetooth.enable = false;
        amdgpu.enable = false;
	# nvidia.enable = true;
        tailscale.enable = false;
        footpedal.enable = false;
      };
    };
    #profiles.desktop.enable = true;
  };
}
