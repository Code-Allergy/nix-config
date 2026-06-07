{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.neer.modules.app.browsers.chromium;
in {
  options.neer.modules.app.browsers.chromium = {
    enable = mkEnableOption "Enable Chromium";
  };
  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      package = pkgs.chromium;
      extensions = [
        # UBlock Origin
        {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";}

        # Bitwarden
        {id = "nngceckbapebfimnlniiiahkandclblb";}

        # Dark Reader
        {id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";}

        # I still don't care about cookies
        {id = "edibdbjcniadpccecjdfdjjppcpchdlm";}

        # Better Canvas
        {id = "cndibmoanboadcifjkjbdpjgfedanolh";}

        # Google Keep
        {id = "lpcaedmchfhocbbapmcbpinfpgnhiddi";}

        # Catppuccin theme
        {id = "bkkmolkhemgaeaeggcmfbghljjjoofoh";}
      ];
    };
  };
}
