{lib, ...}: let
  catalog = import ./ai-model-catalog.nix {inherit lib;};
in {
  # Host-local home-manager overrides for `ampere`.
  imports = [./system.nix];

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
        inherit (catalog) models profiles;

        modelCache = {
          enable = true;
          sourceDirectory = "/tower/ai-models";
          directory = "/var/cache/ai-inference/models";
          maxSizeGiB = 60;
          samba = {
            enable = true;
            share = "//10.10.10.10/AIModels";
          };
        };
        startupProfile = "spark-normal";

        supportServices.searxngInstanceName = "Ampere Search";

        llamaSwap = {
          image = "ghcr.io/mostlygeek/llama-swap:unified-cuda";
          extraOptions = ["--device=nvidia.com/gpu=all"];
          serviceAfter = ["nvidia-container-toolkit-cdi-generator.service"];
        };

        reverseProxy = {
          enable = true;
          webuiHost = "chat.ampere.duckduck112.duckdns.org";
          apiHost = "api.ampere.duckduck112.duckdns.org";
          certificateOwner = "certsync";
          certificateGroup = "cert-deploy";
        };
      };
    };
    #profiles.desktop.enable = true;
  };
}
