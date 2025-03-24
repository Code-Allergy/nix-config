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
  };
}
