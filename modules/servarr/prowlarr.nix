{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.prowlarr;
  servarrEnable = config.ncfg.servarr.enable;
in
{
  options = {
    ncfg.servarr.prowlarr = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = servarrEnable;
        description = "Whether to enable Prowlarr.";
      };
      autoStart = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to start Prowlarr automatically.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."prowlarr" = {
      image = "ghcr.io/hotio/prowlarr";
      inherit (cfg) autoStart;
      environment = {
        "PGID" = "1000";
        "PUID" = "1000";
        "TZ" = config.time.timeZone;
        "UMASK" = "002";
      };
      volumes = [
        "/containers/config/prowlarr:/config:rw"
      ];
      ports = [
        "9696:9696/tcp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network-alias=prowlarr"
        "--network=arr"
      ];
    };
    systemd.services."docker-prowlarr" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "no";
      };
      after = [
        "docker-network-arr.service"
      ];
      requires = [
        "docker-network-arr.service"
      ];
      partOf = [
        "docker-compose-servarr-root.target"
      ];
      wantedBy = lib.mkForce (
        if cfg.autoStart then [
          "docker-compose-servarr-root.target"
        ] else [ ]
      );
    };
  };
}
