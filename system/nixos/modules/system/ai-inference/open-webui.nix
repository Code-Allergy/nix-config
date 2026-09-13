{
  config,
  lib,
  ...
}: let
  cfg = config.neer.modules.services.ai-inference;
  inferenceApiBaseUrl =
    if cfg.openWebui.apiBaseUrl != null
    then cfg.openWebui.apiBaseUrl
    else if cfg.litellm.enable
    then "http://litellm:4000/v1"
    else "http://llama-swap:8080/v1";
  defaultEnvironment = {
    ENABLE_OLLAMA_API = "false";

    ENABLE_OPENAI_API = "true";
    OPENAI_API_BASE_URL = inferenceApiBaseUrl;

    AUDIO_STT_ENGINE = "openai";
    AUDIO_STT_OPENAI_API_BASE_URL = inferenceApiBaseUrl;
    AUDIO_STT_MODEL = "whisper-large-v3-turbo";

    AUDIO_TTS_ENGINE = "openai";
    AUDIO_TTS_OPENAI_API_BASE_URL = "http://kokoro-tts:8880/v1";
    AUDIO_TTS_MODEL = "kokoro";
    AUDIO_TTS_VOICE = "af_bella";

    ENABLE_IMAGE_GENERATION = "true";
    IMAGE_GENERATION_ENGINE = "openai";
    IMAGES_OPENAI_API_BASE_URL = inferenceApiBaseUrl;
    IMAGE_GENERATION_MODEL = "flux2-klein-4b";

    ENABLE_WEB_SEARCH = "true";
    WEB_SEARCH_ENGINE = "searxng";
    SEARXNG_QUERY_URL = "http://searxng:8080/search?q=<query>";
    WEB_SEARCH_RESULT_COUNT = "5";
    WEB_SEARCH_CONCURRENT_REQUESTS = "5";

    VECTOR_DB = "qdrant";
    QDRANT_URI = "http://qdrant:6333";
    ENABLE_QDRANT_MULTITENANCY_MODE = "true";
    QDRANT_COLLECTION_PREFIX = "open-webui";
    QDRANT_PREFER_GRPC = "false";
    QDRANT_TIMEOUT = "10";

    RAG_EMBEDDING_ENGINE = "openai";
    RAG_OPENAI_API_BASE_URL = "http://qwen-embedding:8080/v1";
    RAG_EMBEDDING_MODEL = "qwen3-embedding-0.6b";

    RAG_RERANKING_ENGINE = "external";
    RAG_EXTERNAL_RERANKER_URL = "http://qwen-reranker:8080/v1/rerank";
    RAG_RERANKING_MODEL = "qwen3-reranker-0.6b";
    RAG_TOP_K_RERANKER = "5";
    ENABLE_RAG_HYBRID_SEARCH = "true";
    RAG_TOP_K = "15";

    ENABLE_PERSISTENT_CONFIG = "false";
  };
  publicEnvironment = lib.optionalAttrs (cfg.reverseProxy.enable && cfg.reverseProxy.webuiHost != null) {
    WEBUI_URL = "https://${cfg.reverseProxy.webuiHost}";
    CORS_ALLOW_ORIGIN = "https://${cfg.reverseProxy.webuiHost}";
    WEBUI_SESSION_COOKIE_SECURE = "true";
  };
in {
  options.neer.modules.services.ai-inference.openWebui = {
    enable = lib.mkEnableOption "Open WebUI";

    image = lib.mkOption {
      type = lib.types.str;
      default = "ghcr.io/open-webui/open-webui:main";
    };

    dataDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/open-webui";
    };

    apiBaseUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "OpenAI-compatible inference API URL. Null selects the internal LiteLLM endpoint when enabled, otherwise llama-swap.";
    };

    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };

    port = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      description = "Optional host port for Open WebUI; null leaves it container-only.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Environment overrides for Open WebUI.";
    };

    environmentFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Runtime environment files containing Open WebUI secrets.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.openWebui.enable) {
    systemd.tmpfiles.rules = [
      "d ${cfg.openWebui.dataDirectory} 0750 root root -"
    ];

    virtualisation.oci-containers.containers.open-webui = {
      image = cfg.openWebui.image;
      autoStart = true;
      volumes = ["${cfg.openWebui.dataDirectory}:/app/backend/data"];
      environment = defaultEnvironment // publicEnvironment // cfg.openWebui.environment;
      environmentFiles = cfg.openWebui.environmentFiles;
      ports = lib.optional (cfg.openWebui.port != null) "${cfg.openWebui.bindAddress}:${toString cfg.openWebui.port}:8080";
      extraOptions = [
        "--network=${cfg.networkName}"
        "--security-opt=no-new-privileges"
      ];
    };

    systemd.services.podman-open-webui = {
      requires = ["podman-network-ai.service"];
      wants = lib.optional cfg.litellm.enable "podman-litellm.service";
      after =
        [
          "podman-network-ai.service"
          "podman-llama-swap.service"
        ]
        ++ lib.optional cfg.litellm.enable "podman-litellm.service";
    };
  };
}
