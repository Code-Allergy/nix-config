{lib}: let
  builders = import ../../modules/system/ai-inference/model-builders.nix {inherit lib;};
  inherit (builders) command llamaModel port;
in {
  models = {
    "ling-3.0-tiny-128k" = llamaModel {
      name = "Ling 3.0 Tiny";
      description = "Ling 3.0 Tiny - native 128K context";
      file = "Ling-3.0-tiny-Q4_0.gguf";
      context = 131072;
    };

    "ling-3.0-tiny-256k" = llamaModel {
      name = "Ling 3.0 Tiny XL";
      description = "Ling 3.0 Tiny - 256K YaRN context";
      file = "Ling-3.0-tiny-Q4_0.gguf";
      context = 262144;
      extraArgs = [
        "--rope-scaling yarn"
        "--rope-scale 2"
        "--rope-freq-base 6000000"
        "--yarn-orig-ctx 131072"
      ];
    };

    "spark-2.5-light" = llamaModel {
      name = "Spark X2.5 4B Light";
      description = "Spark X2.5 4B Q4_K_M - fast 16K context";
      file = "Spark-X2.5-4B-Q4_K_M.gguf";
      context = 16384;
    };

    "spark-2.5-normal" = llamaModel {
      name = "Spark X2.5 4B";
      description = "Spark X2.5 4B Q4_K_M - balanced 64K context";
      file = "Spark-X2.5-4B-Q4_K_M.gguf";
      context = 65536;
    };

    "spark-2.5-quality" = llamaModel {
      name = "Spark X2.5 4B Quality";
      description = "Spark X2.5 4B Q8_0 - quality-first 64K context";
      file = "Spark-X2.5-4B-Q8_0.gguf";
      context = 65536;
    };

    "spark-2.5-xl" = llamaModel {
      name = "Spark X2.5 4B XL";
      description = "Spark X2.5 4B Q4_K_M - 320K context";
      file = "Spark-X2.5-4B-Q4_K_M.gguf";
      context = 327680;
      cacheType = "q4_0";
      batch = 512;
      ubatch = 64;
    };

    "qwen-3.5-9b-smart" = llamaModel {
      name = "Qwen 3.5 9B Smart";
      description = "Qwen 3.5 9B Q5_K_M - maximum intelligence, 40K context";
      file = "Qwen3.5-9B-Q5_K_M.gguf";
      context = 40960;
      ubatch = 128;
      extraArgs = ["--jinja"];
    };

    "qwen-3.5-9b-smart-uncensored" = llamaModel {
      name = "Qwen 3.5 9B Smart (uncensored)";
      description = "Qwen 3.5 9B Q4_K_M - maximum intelligence, 40K context, uncensored";
      file = "Qwen3.5-9B-Uncensored-Q4_K_M.gguf";
      context = 40960;
      ubatch = 128;
      extraArgs = ["--jinja"];
    };

    "qwen-3.5-9b-vision" = llamaModel {
      name = "Qwen 3.5 9B Vision";
      description = "Qwen 3.5 9B Q4_K_M + Q8 vision projector - 8K context";
      file = "Qwen3.5-9B-Q4_K_M.gguf";
      extraFiles = ["Qwen3.5-9B-mmproj-F16.gguf"];
      context = 8192;
      ubatch = 128;
      extraArgs = [
        "--mmproj /models/Qwen3.5-9B-mmproj-F16.gguf"
        "--jinja"
      ];
    };

    "qwen-3.5-9b-vision-uncensored" = llamaModel {
      name = "Qwen 3.5 9B Vision (uncensored)";
      description = "Qwen 3.5 9B Q4_K_M + Q8 vision projector - 8K context (uncensored)";
      file = "Qwen3.5-9B-Uncensored-Q4_K_M.gguf";
      extraFiles = ["Qwen3.5-9B-mmproj-F16.gguf"];
      context = 8192;
      ubatch = 128;
      extraArgs = [
        "--mmproj /models/Qwen3.5-9B-mmproj-F16.gguf"
        "--jinja"
      ];
    };

    whisper-large-v3-turbo = {
      cacheFiles = ["ggml-large-v3-turbo-q8_0.bin"];
      name = "Whisper Large V3 Turbo";
      description = "GPU accelerated speech-to-text";
      ttl = 300;
      checkEndpoint = "/";
      cmd = command [
        "whisper-server"
        "--host 127.0.0.1"
        "--port ${port}"
        "-m /models/ggml-large-v3-turbo-q8_0.bin"
        "--language auto"
        "--convert"
        "--tmp-dir /tmp"
        "--inference-path /v1/audio/transcriptions"
      ];
    };

    flux2-klein-4b = {
      cacheFiles = [
        "image/flux-2-klein-4b-Q4_K_M.gguf"
        "image/flux2-klein-4b-uncensored-q4_k_m.gguf"
        "image/ae.safetensors"
      ];
      name = "FLUX.2 Klein 4B";
      description = "FLUX.2 Klein 4B with uncensored Qwen text encoder";
      ttl = 300;
      checkEndpoint = "/v1/models";
      cmd = command [
        "sd-server"
        "--listen-ip 127.0.0.1"
        "--listen-port ${port}"
        "--diffusion-model /models/image/flux-2-klein-4b-Q4_K_M.gguf"
        "--llm /models/image/flux2-klein-4b-uncensored-q4_k_m.gguf"
        "--vae /models/image/ae.safetensors"
        "--cfg-scale 1.0"
        "--steps 4"
        "--diffusion-fa"
        "--offload-to-cpu"
      ];
    };
  };

  profiles = {
    ling-normal = {
      description = "Ling - fast general inference with native 128K context";
      pins.chat = "ling-3.0-tiny-128k";
    };
    ling-xl = {
      description = "Ling - extended 256K context";
      pins.chat = "ling-3.0-tiny-256k";
    };
    spark-light = {
      description = "Spark - maximum interactive speed, 16K context";
      pins.chat = "spark-2.5-light";
    };
    spark-normal = {
      description = "Spark - balanced Q4_K_M profile, 64K context";
      pins.chat = "spark-2.5-normal";
    };
    spark-quality = {
      description = "Spark - Q8_0 quality-first profile, 64K context";
      pins.chat = "spark-2.5-quality";
    };
    spark-xl = {
      description = "Spark - maximum-context 320K profile";
      pins.chat = "spark-2.5-xl";
    };
    qwen-smart = {
      description = "Qwen 3.5 9B - highest intelligence local profile";
      pins.chat = "qwen-3.5-9b-smart";
    };
    qwen-smart-uncensored = {
      description = "Qwen 3.5 9B - highest intelligence local profile (uncensored)";
      pins.chat = "qwen-3.5-9b-smart-uncensored";
    };
    qwen-vision = {
      description = "Qwen 3.5 9B - multimodal image and text reasoning";
      pins.chat = "qwen-3.5-9b-vision";
    };
    qwen-vision-uncensored = {
      description = "Qwen 3.5 9B - multimodal image and text reasoning (uncensored)";
      pins.chat = "qwen-3.5-9b-vision-uncensored";
    };
  };
}
