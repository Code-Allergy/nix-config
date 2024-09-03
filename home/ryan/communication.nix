{pkgs, ...}: {
  home.packages = with pkgs; [
    # discord
    # discocss
    vesktop
    trilium-desktop # not sure where to put this just yet.
  ];
}
