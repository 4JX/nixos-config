{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.authentik.worker;
  servarrEnable = config.ncfg.servarr.enable;
  authentikEnable = config.ncfg.servarr.authentik.enable;

  secretsFile.sopsFile = config.ncfg.servarr.secretsFolder + "/servarr.yaml";
in
{
  options = {
    ncfg.servarr.authentik.worker.enable = lib.mkOption {
      type = lib.types.bool;
      default = authentikEnable && servarrEnable;
      description = "Whether to enable the Authentik worker.";
    };
  };

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
      };
      environmentFiles = [
        config.sops.secrets.authentik-env.path
      ];
      volumes = [
        "/containers/authentik/authentik/certs:/certs:rw"
        "/containers/authentik/authentik/custom-templates:/templates:rw"
        "/containers/authentik/authentik/media:/media:rw"
        "/var/run/docker.sock:/var/run/docker.sock:rw"
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
      ];
      requires = [
        "docker-network-authentik.service"
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
