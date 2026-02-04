{ pkgs, ... }:
{
  # Enable Mullvad VPN
  # services.mullvad-vpn.enable = true;
  # `pkgs.mullvad` only provides the CLI tool, use `pkgs.mullvad-vpn` instead if you want to use the CLI and the GUI.
  # services.mullvad-vpn.package = pkgs.mullvad;
  services.tailscale.enable = true;
  

  # environment.systemPackages = with pkgs; [
    # mullvad-closest
  # ];
}
