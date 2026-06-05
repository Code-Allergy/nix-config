{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.neer.modules.app.office;
in
{
  options.neer.modules.app.office = {
    enable = mkEnableOption "Enable office packages" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      onlyoffice-desktopeditors
      libreoffice-qt
      hunspell
      hunspellDicts.uk_UA
      hunspellDicts.th_TH
    ];
  };
}
