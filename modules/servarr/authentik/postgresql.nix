{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.authentik.postgresql;
  servarrEnable = config.ncfg.servarr.enable;
  authentikEnable = config.ncfg.servarr.authentik.enable;

  secretsFile.sopsFile = config.ncfg.servarr.secretsFolder + "/servarr.yaml";
in
{
  options = {
    ncfg.servarr.authentik.postgresql.enable = lib.mkOption {
      type = lib.types.bool;
      default = authentikEnable && servarrEnable;
      description = "Whether to enable the Authentik postgresql database.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.authentik-postgresql-env = secretsFile;

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."authentik-postgresql" = {
      image = "docker.io/library/postgres:16-alpine";
      environmentFiles = [
        config.sops.secrets.authentik-postgresql-env.path
      ];
      volumes = [
        "/containers/authentik/postgresql:/var/lib/postgresql/data:rw"
      ];
      log-driver = "journald";
      extraOptions = [
        "--health-cmd=pg_isready -d \${POSTGRES_DB} -U \${POSTGRES_USER}"
        "--health-interval=30s"
        "--health-retries=5"
        "--health-start-period=20s"
        "--health-timeout=5s"
        "--network-alias=postgresql"
        "--network=authentik"
      ];
    };
    systemd.services."podman-authentik-postgresql" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "always";
      };
      after = [
        "podman-network-authentik.service"
      ];
      requires = [
        "podman-network-authentik.service"
      ];
      partOf = [
        "podman-compose-servarr-root.target"
      ];
      wantedBy = [
        "podman-compose-servarr-root.target"
      ];
    };
  };
}
