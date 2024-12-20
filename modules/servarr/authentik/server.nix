{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.authentik.server;
  servarrEnable = config.ncfg.servarr.enable;
  authentikEnable = config.ncfg.servarr.authentik.enable;

  secretsFile.sopsFile = config.ncfg.servarr.secretsFolder + "/servarr.yaml";
in
{
  options = {
    ncfg.servarr.authentik.server.enable = lib.mkOption {
      type = lib.types.bool;
      default = authentikEnable && servarrEnable;
      description = "Whether to enable the Authentik server.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.authentik-env = secretsFile;

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."authentik-server" = {
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
        "/containers/authentik/authentik/custom-templates:/templates:rw"
        "/containers/authentik/authentik/media:/media:rw"
      ];
      ports = [
        "9000:9000/tcp"
        "9443:9443/tcp"
      ];
      cmd = [ "server" ];
      dependsOn = [
        "authentik-postgresql"
        "authentik-redis"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network-alias=server"
        "--network=authentik"
        "--network=exposed"
        "--network=ldap"
      ];
    };
    systemd.services."docker-authentik-server" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "always";
        RestartMaxDelaySec = lib.mkOverride 90 "1m";
        RestartSec = lib.mkOverride 90 "100ms";
        RestartSteps = lib.mkOverride 90 9;
      };
      after = [
        "docker-network-authentik.service"
        "docker-network-ldap.service"
      ];
      requires = [
        "docker-network-authentik.service"
        "docker-network-ldap.service"
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
