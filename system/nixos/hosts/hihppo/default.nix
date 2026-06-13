{pkgs, ...}: {
  neer = {
    modules = {
      user.home = ./home.nix;
      system = {
        wsl2.enable = true;
      };
    };

    profiles.work.enable = true;
  };
}
