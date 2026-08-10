{
  config,
  lib,
  trilium-notes,
  inputs,
  ...
}:
with lib; let
  cfg = config.neer.modules.app.trilium;
in {
  options.neer.modules.app.trilium = {
    enable = mkEnableOption "Enable Trilium";
  };

  config = mkIf cfg.enable {
    home.packages = [
      inputs.trilium-notes.packages.x86_64-linux.desktop
    ];
  };
}
