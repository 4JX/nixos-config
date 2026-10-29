{
  pkgs,
  ...
}:

let
  # HuggingFaceModelDownloader is not currently packaged in nixpkgs,
  # so install the upstream static Linux x86_64 binary.
  hfdownloader = pkgs.stdenvNoCC.mkDerivation {
    pname = "hfdownloader";
    version = "3.2.0";

    src = pkgs.fetchurl {
      url = "https://github.com/bodaay/HuggingFaceModelDownloader/releases/download/v3.2.0/hfdownloader_linux_amd64_v3.2.0";
      hash = "sha256-lWIq+ej1NbwbpWmu1Q549M/AXXe9n1PXFn19clrY5zQ=";
    };

    dontUnpack = true;

    installPhase = ''
      install -Dm755 "$src" "$out/bin/hfdownloader"
    '';

    meta = {
      description = "Fast Hugging Face model downloader";
      homepage = "https://github.com/bodaay/HuggingFaceModelDownloader";
      license = pkgs.lib.licenses.asl20;
      platforms = [ "x86_64-linux" ];
      mainProgram = "hfdownloader";
    };
  };

  modelDir = "/srv/llm-models";
  llamaCpp = pkgs.callPackage ./llama-cpp/package.nix { };
  llamaModelsPreset = toString ./llama-cpp/models.ini;

  llamaCudaUnfree = [
    "cuda_cccl"
    "cuda_cudart"
    "cuda_nvcc"
    "libcublas"
    "cuda_nvml_dev"
    "cuda_nvrtc"
    "cccl"
    "libnvvm"
    "cuda_crt"
  ];

in
{
  imports = [
    ./deepseek-harness
    ./comfyui.nix
  ];

  # Should probably live elsewhere, but currently only the AI shenanigans use containers in Terra
  virtualisation = {
    podman.enable = true;
    oci-containers.backend = "podman";
  };

  local = {
    allowedUnfree = [
      "open-webui"
    ]
    ++ llamaCudaUnfree;
  };

  # Shared model directory
  systemd.tmpfiles.rules = [
    "d ${modelDir} 1777 root root -"
  ];

  services.llama-cpp = {
    enable = true;

    package = llamaCpp;

    settings = {
      host = "127.0.0.1";
      port = 8081;

      # Router mode to hot swap models
      models-dir = modelDir;
      models-preset = llamaModelsPreset;

      models-max = 1;
      models-autoload = true;
    };
  };

  systemd.services.llama-cpp.environment = {
    # Linux 7.2 can disable file-backed mmap readahead after 100 sparse faults.
    # Use sequential advice while loading and processing prompts.
    LLAMA_MMAP_SEQUENTIAL = "1";

    # Sparse MoE generation revisits expert pages non-sequentially, so restore
    # adaptive readahead after prefill. MADV_RANDOM was substantially slower.
    LLAMA_MMAP_GENERATION_ADVICE = "normal";
  };

  services.open-webui = {
    enable = true;
    host = "127.0.0.1";
    port = 3000;

    environment = {
      ENABLE_OLLAMA_API = "False";
      ENABLE_OPENAI_API = "True";
      OPENAI_API_BASE_URL = "http://127.0.0.1:8081/v1";
      OPENAI_API_KEY = "local";
      WEBUI_AUTH = "false";

      ENABLE_KB_EXEC = "True";

      # Telemetry / analytics opt-outs (not sure these do anything)

      # Open WebUI / dependencies
      DO_NOT_TRACK = "true";
      SCARF_NO_ANALYTICS = "true";

      # ChromaDB
      ANONYMIZED_TELEMETRY = "false";

      # Hugging Face ecosystem
      HF_HUB_DISABLE_TELEMETRY = "1";

      # OpenTelemetry
      ENABLE_OTEL = "false";
      ENABLE_OTEL_TRACES = "false";
      ENABLE_OTEL_METRICS = "false";
      ENABLE_OTEL_LOGS = "false";
    };
  };

  environment.systemPackages = with pkgs; [
    llamaCpp

    hfdownloader

    curl
    jq
    nvtopPackages.nvidia

    # Launch the HuggingFaceModelDownloader Web UI with the
    # correct model directory already configured.
    (writeShellScriptBin "hfdownloader-ui" ''
      exec ${hfdownloader}/bin/hfdownloader serve \
        --addr 127.0.0.1 \
        --port 8082 \
        --models-dir ${modelDir}
    '')

    # Convenience command for direct downloads:
    #
    #   hfd owner/repo:q4_k_m
    #
    # Everything is dropped directly into /srv/llm-models.
    (writeShellScriptBin "hfd" ''
      set -e

      ${hfdownloader}/bin/hfdownloader download \
        "$@" \
        --local-dir ${modelDir}

      echo
      echo "Exposing GGUFs to llama-server..."

      find ${modelDir} \
        -mindepth 3 \
        -type f \
        -name '*.gguf' \
        -print0 |
      while IFS= read -r -d "" model; do
        name="$(basename "$model")"
        dest="${modelDir}/$name"

        # Already hardlinked correctly.
        if [ -e "$dest" ] && [ "$model" -ef "$dest" ]; then
          continue
        fi

        # Don't overwrite an unrelated root-level model with the same name.
        if [ -e "$dest" ] || [ -L "$dest" ]; then
          echo "Skipping $name: ${modelDir}/$name already exists"
          continue
        fi

        ln "$model" "$dest"
        echo "  $name"
      done

      echo
      echo "Refreshing llama-server..."

      ${curl}/bin/curl \
        --silent \
        --fail \
        'http://127.0.0.1:8081/models?reload=1' \
        >/dev/null || true
    '')

    # Ask llama-server to rescan /srv/llm-models after downloading.
    (writeShellScriptBin "llama-refresh" ''
      ${curl}/bin/curl \
        --silent \
        --fail \
        'http://127.0.0.1:8081/models?reload=1' |
        ${jq}/bin/jq
    '')
  ];
}
