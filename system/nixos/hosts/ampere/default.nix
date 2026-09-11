{...}: {
  # Host-local home-manager overrides for `bigblubbus`.
  imports = [./system.nix];

  neer = {
    modules = {
      user.home = ./home.nix;
      system = {
        oci.enable = true;
      };

      services.ai-inference = {
        enable = true;
        listenAddress = "127.0.0.1";
      };
    };
    #profiles.desktop.enable = true;
  };
}
