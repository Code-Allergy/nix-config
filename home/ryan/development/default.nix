{
  inputs,
  pkgs,
  lib,
  isHeaded,
  ...
}:
{
  imports = lib.flatten [
    [
      ./git.nix
      ./distrobox.nix
    ]
    (lib.optionals isHeaded [
      ./headed.nix
    ])
  ];

  home.packages = with pkgs; [
    gdb
    gcc
    gnumake
    cmake
    python312
    nodejs_22
    jdk21_headless
    clang-tools
    tealdeer
    nil
    nixfmt-rfc-style
    wakatime
    inputs.tsutsumi.packages.${pkgs.system}.wakatime-ls

    # network tools
    wget
    curl

    android-tools

    # Github/Gitlab CLI
    gh
    glab
  ];

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "11.0.0";
    };

  };

  # Declarative virtmanager configuration, not sure where to place this
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

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
}
