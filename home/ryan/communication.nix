{pkgs, ...}: {
  home.packages = with pkgs; [
    vesktop
    trilium-desktop # not sure where to put this just yet.
  ];
}
