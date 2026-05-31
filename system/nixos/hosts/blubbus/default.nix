{ ... }:
{
  imports = [ ./system.nix ];

  # Host-local home-manager overrides for `blubbus`.
  # This will later be replaced by a higher-level profile with local overrides.
  neer.modules.user.home = ./home.nix;
}
