{
  config,
  pkgs,
  userConf,
  inputs,
  hostname,
  ...
}:
with pkgs;
with userConf;
{
  system.stateVersion = "24.05";
  # programs.zsh.enable = true;
  # security.sudo.wheelNeedsPassword = false;
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    registry = {
      nixpkgs = {
        flake = inputs.nixpkgs;
      };
    };
  };
}
