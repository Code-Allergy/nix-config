{
  config,
  lib,
  ...
}: let
  catalog = import ./ai-model-catalog.nix {inherit lib;};
  optimusCatalog = import ../optimus/ai-model-catalog.nix {inherit lib;};
  ampereModels = ["chat"] ++ builtins.attrNames catalog.models;
  optimusModels = ["chat"] ++ builtins.attrNames optimusCatalog.models;
in {
  # Host-local home-manager overrides for `ampere`.
  imports = [./system.nix];

  age = {
    identityPaths = lib.mkForce ["/etc/ssh/ssh_host_ed25519_key"];
    secrets = {
      ai-ampere-worker-env = {
        file = ../../../shared/secrets/ai-ampere-worker.env.age;
        owner = "root";
        mode = "0400";
      };
      ai-open-webui-env = {
        file = ../../../shared/secrets/ai-open-webui.env.age;
        owner = "root";
        mode = "0400";
      };
      ai-litellm-env = {
        file = ../../../shared/secrets/ai-litellm.env.age;
        owner = "root";
        mode = "0400";
      };
      ai-litellm-postgres-env = {
        file = ../../../shared/secrets/ai-litellm-postgres.env.age;
        owner = "root";
        mode = "0400";
      };
    };
  };

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

        openWebui = {
          enable = true;
          environmentFiles = [config.age.secrets.ai-open-webui-env.path];
        };

        llamaSwap = {
          image = "ghcr.io/mostlygeek/llama-swap:unified-cuda";
          extraOptions = ["--device=nvidia.com/gpu=all"];
          serviceAfter = ["nvidia-container-toolkit-cdi-generator.service"];
          environmentFiles = [config.age.secrets.ai-ampere-worker-env.path];
          apiKeyEnvironmentVariable = "LLAMA_SWAP_API_KEY";
        };

        litellm = {
          enable = true;
          environmentFiles = [config.age.secrets.ai-litellm-env.path];
          database.environmentFiles = [config.age.secrets.ai-litellm-postgres-env.path];
          backends = {
            ampere = {
              apiBase = "http://llama-swap:8080/v1";
              apiKeyEnvironmentVariable = "AMPERE_API_KEY";
              models = ampereModels;
              modelModes = {
                flux2-klein-4b = "image_generation";
                whisper-large-v3-turbo = "audio_transcription";
              };
              tags = [
                "cuda"
                "rtx-3070"
              ];
              order = 1;
            };
            optimus = {
              apiBase = "https://optimus.${config.neer.network.rootDomain}/v1";
              apiKeyEnvironmentVariable = "OPTIMUS_API_KEY";
              models = optimusModels;
              modelModes = {
                flux2-klein-4b = "image_generation";
                whisper-large-v3-turbo = "audio_transcription";
              };
              tags = [
                "vulkan"
                "rx-7900-xt"
              ];
              order = 2;
            };
          };
        };

        grafanaMcp = {
          enable = true;
          environmentFiles = [config.age.secrets.ai-litellm-env.path];
        };

        reverseProxy = {
          enable = true;
          host = "api.${config.networking.hostName}.${config.neer.network.baseDomain}";
          webuiHost = "chat.${config.networking.hostName}.${config.neer.network.baseDomain}";
          upstream = "litellm:4000";
          allowedRemoteRanges = [];
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
