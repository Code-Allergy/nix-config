{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let # This can be a languages/rust.nix file later or something
  devCfg = config.global.config.development;
  cfg = devCfg.rust;
in
{
  options.global.config.development.rust.enable = mkEnableOption "Enable Rust" // {
    default = devCfg.enable; # Inherit enable state from main module
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (rust-bin.fromRustupToolchainFile ./rust-toolchain.toml)
      lldb_16
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
      cargo-spellcheck
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
