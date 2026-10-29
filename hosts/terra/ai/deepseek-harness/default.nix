{ lib, pkgs, ... }:

let
  version = "0.2.0-rc.2";
  image = "deepseek-harness-workstation:${version}";
  workspace = "/home/infinity/Documents/dsh";
in
{
  systemd.tmpfiles.rules = [
    "d ${workspace} 0750 infinity users -"
  ];

  # The OCI module owns the runtime service. Build the local image in that
  # service's pre-start phase so a failed build follows its normal retry path.
  systemd.services.podman-deepseek-harness = {
    path = [ pkgs.podman ];
    preStart = lib.mkBefore ''
      podman build \
        --build-arg DSH_VERSION=${version} \
        --tag ${image} \
        ${./.}
    '';
    serviceConfig.RestartSec = "10s";
  };

  virtualisation.oci-containers.containers.deepseek-harness = {
    image = image;
    pull = "never";
    cmd = [
      "dsh"
      "web"
      "--no-open"
    ];

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
      "${workspace}:/workspace"
    ];
  };
}
