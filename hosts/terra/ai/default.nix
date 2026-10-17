{
  lib,
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
  deepseekHarnessVersion = "0.1.7-rc.2";
  deepseekHarnessImage = "deepseek-harness-workstation:${deepseekHarnessVersion}";

  llamaModelsPreset = toString ./llama-models.ini;
in
{
  local = {
    allowedUnfree = [
      "cuda_cccl"
      "cuda_cudart"
      "cuda_nvcc"
      "libcublas"
      "open-webui"
      "cuda_nvml_dev"
      "cuda_nvrtc"
    ];
  };

  # Shared model directory.
  #
  # Your normal user can download models here and llama.cpp's
  # sandboxed service can read them.
  systemd.tmpfiles.rules = [
    "d ${modelDir} 1777 root root -"
    "d /home/infinity/Documents/dsh 0750 infinity users -"
  ];

  services.llama-cpp = {
    enable = true;

    package = pkgs.llama-cpp.override {
      cudaSupport = true;
    };

    settings = {
      host = "127.0.0.1";
      port = 8081;

      # Router mode because no fixed `model` is specified.
      models-dir = modelDir;
      models-preset = llamaModelsPreset;

      models-max = 1;
      models-autoload = true;
    };
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

  # Build the conventional Debian image into the local Docker daemon before
  # the generated OCI container service starts. Docker's layer cache keeps
  # unchanged boots cheap while changes to the Dockerfile trigger a rebuild.
  systemd.services.deepseek-harness-image = {
    description = "Build the DeepSeek Harness workstation image";
    requires = [ "docker.service" ];
    after = [
      "docker.service"
      "docker.socket"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    before = [ "docker-deepseek-harness.service" ];

    path = [ pkgs.docker ];
    script = ''
      docker build \
        --build-arg DSH_VERSION=${deepseekHarnessVersion} \
        --tag ${deepseekHarnessImage} \
        ${./deepseek-harness}
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  systemd.services.docker-deepseek-harness = {
    requires = [ "deepseek-harness-image.service" ];
    after = [ "deepseek-harness-image.service" ];
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers.deepseek-harness = {
      image = deepseekHarnessImage;
      pull = "never";
      cmd = [
        "dsh"
        "web"
        "--no-open"
      ];

      # dsh intentionally binds only to loopback. Host networking preserves
      # that restriction while making the UI available at 127.0.0.1:3080.
      extraOptions = [
        "--network=host"
        "--cap-drop=ALL"
        "--security-opt=no-new-privileges"
        "--init"
      ];

      user = "1000:100";
      workdir = "/workspace";
      environment = {
        DSH_HOME = "/workspace/.dsh";
        npm_config_cache = "/workspace/.dsh/npm-cache";
      };
      volumes = [
        "/home/infinity/Documents/dsh:/workspace"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    (llama-cpp.override {
      cudaSupport = true;
    })

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
