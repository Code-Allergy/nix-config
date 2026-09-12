{lib, ...}: let
  catalog = import ./ai-model-catalog.nix {inherit lib;};
in {
  # Host-local home-manager overrides for `optimus`.
  imports = [./system.nix];

  neer = {
    modules = {
      user.home = ./home.nix;
      system = {
        oci.enable = true;
        gaming.enable = true;
        virtualization.enable = true;
        bluetooth.enable = true;
        amdgpu.enable = true;
        tailscale.enable = true;
        footpedal.enable = true;
        home-net-syslogging = {
          enable = true;
          extraLabels = {
            role = "desktop";
          };
        };
      };

      services.ai-inference = {
        enable = true;
        inherit (catalog) models profiles;

        modelCache = {
          enable = true;
          sourceDirectory = "/tower/ai-models";
          directory = "/agentic/models";
          maxSizeGiB = 60;
          samba = {
            enable = true;
            share = "//10.10.10.10/AIModels";
          };
        };
        startupProfile = "spark-normal";

        supportServices.searxngInstanceName = "Optimus Search";

        llamaSwap = {
          image = "ghcr.io/mostlygeek/llama-swap:unified-vulkan";
          devices = [
            "/dev/dri/card1:/dev/dri/card0"
            "/dev/dri/renderD128:/dev/dri/renderD128"
          ];
          port = 8080;
        };

        openWebui.port = 3000;
      };
    };
    profiles.desktop.enable = true;
  };
}
