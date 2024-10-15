{
  pkgs,
  lib,
  isHeaded,
  ...
}: {
  imports = lib.flatten [
    [
      ./git.nix
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

    # network tools
    wget
    curl

    distrobox

    android-tools

    # Github/Gitlab CLI
    gh
    glab
  ];

  # Declarative virtmanager configuration, not sure where to place this
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
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
    coc.settings = {};

    plugins = with pkgs.vimPlugins; [
      vim-fugitive
      vim-vinegar
      # nodePackages.bash-language-server
      # nodePackages.typescript-language-server
      # nodePackages.vim-language-server
      # nodePackages.yaml-language-server
      # python310Packages.python-lsp-server

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
