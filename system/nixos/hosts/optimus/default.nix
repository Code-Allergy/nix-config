{
  config,
  lib,
  ...
}: let
  catalog = import ./ai-model-catalog.nix {inherit lib;};
in {
  # Host-local home-manager overrides for `optimus`.
  imports = [./system.nix];

  age = {
    identityPaths = lib.mkForce ["/etc/ssh/ssh_host_ed25519_key"];
    secrets.ai-optimus-worker-env = {
      file = ../../../shared/secrets/ai-optimus-worker.env.age;
      owner = "root";
      mode = "0400";
    };
  };

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
          environmentFiles = [config.age.secrets.ai-optimus-worker-env.path];
          apiKeyEnvironmentVariable = "LLAMA_SWAP_API_KEY";
        };

        reverseProxy = {
          enable = true;

          allowedRemoteRanges = [
            "10.10.0.20/32"
            "10.10.0.37/32"
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
    profiles.desktop.enable = true;
  };
}
