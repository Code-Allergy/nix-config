{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  devCfg = config.neer.modules.dev;
  cfg = devCfg.rust;
in
{
  options.neer.modules.dev.rust.enable = mkEnableOption "Enable Rust" // {
    default = devCfg.enable; # Inherit enable state from main module
  };

  config = mkIf cfg.enable {
    # TODO: Re-enable the Rust toolchain + rust-overlay once the refactor settles.
    # For now we keep the Rust helper tools that don't require the toolchain package.
    home.packages = with pkgs; [
      taplo # toml formatter & lsp
      cargo-watch
      cargo-deny
      cargo-audit
      cargo-update
      cargo-edit
      cargo-outdated
      cargo-license
      cargo-tarpaulin
      cargo-cross
      cargo-zigbuild
      cargo-nextest
      cargo-modules
      cargo-bloat
      cargo-binstall
      cargo-unused-features
      bacon
      trunk
      mold
    ];
  };
}
