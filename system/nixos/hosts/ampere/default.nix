{ ... }: {
  # Host-local home-manager overrides for `bigblubbus`.
  imports = [ ./system.nix ];

  neer = {
    modules = {
      user.home = ./home.nix;
      system = {
        oci.enable = true;
        home-net-syslogging = {
          enable = true;
          extraLabels = {
            hypervisor = "bigblubbus";
            vm_id = "100";
            role = "ai";
          };
        };
      };

      services.ai-inference = {
        enable = true;

        webuiHost = "chat.ampere.duckduck112.duckdns.org";
        apiHost = "api.ampere.duckduck112.duckdns.org";
      };
    };
    #profiles.desktop.enable = true;
  };
}
