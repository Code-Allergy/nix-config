{
  config,
  lib,
  ...
}: let
  catalog = import ./ai-model-catalog.nix {inherit lib;};
in {
  # Host-local home-manager overrides for `ampere`.
  imports = [./system.nix];

  neer = {
    network.baseDomain = "bigblubbus.${config.neer.network.rootDomain}";

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
          host = "api.${config.networking.hostName}.${config.neer.network.baseDomain}";

          allowedRemoteRanges = [
            "10.10.0.20/32"
            "10.10.10.10/32"
          ];
          certificateDeployment = {
            enable = true;
            authorizedKeys = [
              ''restrict,from="10.10.0.1" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN+5TwqdSKk9szm4YC6tYYovLy6vumlUhYKCNYidgF8Q root@router.lan''
            ];
          };
        };
      };
    };
    #profiles.desktop.enable = true;
  };
}
