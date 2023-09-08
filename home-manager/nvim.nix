{pkgs, ...}: {
  #add to this later
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    coc.enable = true;
    coc.pluginConfig = "";
    coc.settings = {};

    plugins = with pkgs.vimPlugins; [
      vim-fugitive
      nvim-lspconfig
      # nodePackages.bash-language-server
      # nodePackages.typescript-language-server
      # nodePackages.vim-language-server
      # nodePackages.yaml-language-server
      # python311Packages.python-lsp-server

      coc-python
      coc-spell-checker
      coc-sh
      coc-rust-analyzer
      coc-prettier
      coc-nginx
      coc-lua
      coc-json
      coc-toml
      coc-java
      coc-html
      coc-css
      coc-tsserver
      coc-cmake
      coc-docker
      coc-git
    ];
  };
}
