{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.authentik.redis;
  servarrEnable = config.ncfg.servarr.enable;
  authentikEnable = config.ncfg.servarr.authentik.enable;
in
{
  options = {
    ncfg.servarr.authentik.redis.enable = lib.mkOption {
      type = lib.types.bool;
      default = authentikEnable && servarrEnable;
      description = "Whether to enable the Authentik redis database.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."authentik-redis" = {
      image = "docker.io/library/redis:alpine";
      volumes = [
        "/containers/authentik/redis:/data:rw"
      ];
      cmd = [ "--save" "60" "1" "--loglevel" "warning" ];
      log-driver = "journald";
      extraOptions = [
        "--health-cmd=redis-cli ping | grep PONG"
        "--health-interval=30s"
        "--health-retries=5"
        "--health-start-period=20s"
        "--health-timeout=3s"
        "--network-alias=redis"
        "--network=authentik"
      ];
    };
    systemd.services."docker-authentik-redis" = {
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
