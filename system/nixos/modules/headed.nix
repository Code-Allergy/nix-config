{ ... }:
{
  ## COMMON - HEADED
  imports = [
    ./fonts.nix
  ];

  # Theme
  catppuccin = {
    flavor = "mocha";
    enable = true;
    autoEnable = true;
  };

  # services.open-webui = {
  #   enable = true;
  #   port = 8888;
  # };
}
