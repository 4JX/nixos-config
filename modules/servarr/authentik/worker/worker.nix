{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.authentik.worker;

  secretsFile.sopsFile = config.ncfg.servarr.secretsFolder + "/servarr.yaml";
in
{
  config = lib.mkIf cfg.enable {
    sops.secrets.authentik-env = secretsFile;

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."authentik-worker" = {
      image = "ghcr.io/goauthentik/server:2024.10.5";
      environment = {
        "AUTHENTIK_DISABLE_STARTUP_ANALYTICS" = "true";
        "AUTHENTIK_ERROR_REPORTING__ENABLED" = "false";
        "AUTHENTIK_POSTGRESQL__HOST" = "postgresql";
        "AUTHENTIK_REDIS__HOST" = "redis";
        "DOCKER_HOST" = "tcp://dockerproxy-authentik-worker:2375";
      };
      environmentFiles = [
        config.sops.secrets.authentik-env.path
      ];
      volumes = [
        "/containers/authentik/authentik/certs:/certs:rw"
        "/containers/authentik/authentik/custom-templates:/templates:rw"
        "/containers/authentik/authentik/media:/media:rw"
      ];
      cmd = [ "worker" ];
      dependsOn = [
        "authentik-postgresql"
        "authentik-redis"
      ];
      user = "root";
      log-driver = "journald";
      extraOptions = [
        "--network-alias=worker"
        "--network=authentik"
        "--network=socket-proxy-authentik-worker"
      ];
    };
    systemd.services."docker-authentik-worker" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "always";
        RestartMaxDelaySec = lib.mkOverride 90 "1m";
        RestartSec = lib.mkOverride 90 "100ms";
        RestartSteps = lib.mkOverride 90 9;
      };
      after = [
        "docker-network-authentik.service"
        "docker-network-socket-proxy-authentik-worker.service"
      ];
      requires = [
        "docker-network-authentik.service"
        "docker-network-socket-proxy-authentik-worker.service"
      ];
      partOf = [
        "docker-compose-servarr-root.target"
      ];
      wantedBy = [
        "docker-compose-servarr-root.target"
      ];
    };
  };
}
