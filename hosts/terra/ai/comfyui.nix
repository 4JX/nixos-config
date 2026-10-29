{ lib, ... }:
let
  root = "/srv/comfyui";
in
{
  # Previous native approaches, kept here as breadcrumbs:
  # - utensils/comfyui-nix: better than base cache wise, but still had lots of
  #   CUDA builds needed.
  # - nixified-ai's ComfyUI module: worked after local patches, but made model
  #   and co. management a pain for "this type of app"
  # So essentially give up and embrace prebuilt in a disposable FSH docker image

  hardware.nvidia-container-toolkit.enable = true;

  systemd.tmpfiles.rules = [
    "d ${root} 2775 root users -"
  ]
  ++ map (path: "d ${root}/${path} 2775 root users -") [
    "cache"
    "config"
    "local"
    "custom-nodes"
    "models"
    "input"
    "output"
    "user"
    "user-scripts"
  ];

  virtualisation.oci-containers.containers.comfyui = {
    image = "docker.io/yanwk/comfyui-boot:cu130-slim-v2-20261027";
    ports = [ "127.0.0.1:8188:8188" ];

    volumes = [
      "${root}/cache:/root/.cache"
      "${root}/config:/root/.config"
      "${root}/local:/root/.local"
      "${root}/custom-nodes:/root/ComfyUI/custom_nodes"
      "${root}/models:/root/ComfyUI/models"
      "${root}/input:/root/ComfyUI/input"
      "${root}/output:/root/ComfyUI/output"
      "${root}/user:/root/ComfyUI/user"
      "${root}/user-scripts:/root/user-scripts"
    ];

    environment.CLI_ARGS = "";

    extraOptions = [
      "--device=nvidia.com/gpu=all"
      "--security-opt=label=disable"
      "--init"
    ];
  };

  systemd.services.podman-comfyui = {
    after = [ "nvidia-container-toolkit-cdi-generator.service" ];
    requires = [ "nvidia-container-toolkit-cdi-generator.service" ];

    # Pulling the initial multi-gigabyte image can exceed systemd's default.
    serviceConfig.TimeoutStartSec = lib.mkForce "30min";
  };
}
