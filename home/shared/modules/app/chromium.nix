{pkgs, ...}: {
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
}
