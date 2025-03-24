{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  devCfg = config.global.config.development;
  cfg = devCfg.nvim;
in
{
  options.global.config.development.nvim.enable = mkEnableOption "Enable Neovim" // {
    default = devCfg.enable; # Inherit enable state from main module
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      coc.enable = true;
      coc.pluginConfig = "";
      coc.settings = { };

      plugins = with pkgs.vimPlugins; [
        vim-fugitive
        vim-vinegar
        vim-nix
        # nodePackages.bash-language-server
        # nodePackages.typescript-language-server
        # nodePackages.vim-language-server
        # nodePackages.yaml-language-server
        # python310Packages.python-lsp-server

        # TODO changed in 24.11
        # coc-python
        # coc-spell-checker
        # coc-sh
        # coc-rust-analyzer
        # coc-prettier
        # coc-nginx
        # coc-lua
        # coc-json
        # coc-toml
        # coc-java
        # coc-html
        # coc-css
        # coc-tsserver
        # coc-cmake
        # coc-docker
        # coc-git
      ];

      extraLuaConfig = ''
        -- Use a dark background
        vim.o.background = "dark"

        -- Set line numbers
        vim.wo.number = true
        vim.wo.relativenumber = true  -- Enable relative line numbers

        -- Enable syntax highlighting
        vim.cmd('syntax enable')

        -- Autoindentation
        vim.o.autoindent = true
        vim.o.smartindent = true
        vim.o.tabstop = 4
        vim.o.shiftwidth = 4
        vim.o.expandtab = true

        -- Show matching parentheses
        vim.o.showmatch = true

        -- Enable line and column numbers in status
        vim.o.ruler = true

        -- Enable syntax-based folding
        vim.o.foldlevel = 1

        -- Highlight the current line
        vim.o.cursorline = true

        -- Set colorcolumn to 80 characters
        vim.o.colorcolumn = "80"

        -- Enable file type detection based on file extension
        vim.cmd('filetype on')
        vim.cmd('filetype indent plugin on')

        -- One tab will look the same as 4 spaces
        vim.o.tabstop = 4

        -- Set UTF-8 encoding
        vim.o.encoding = "UTF-8"
      '';
    };
  };
}
