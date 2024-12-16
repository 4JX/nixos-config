{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.jellyseerr;
  servarrEnable = config.ncfg.servarr.enable;

  openFirewall = cfg.firewall.open && cfg.firewall.port != null;
  port = cfg.firewall.port;
  portString = builtins.toString port;
in
{
  options = {
    ncfg.servarr.jellyseerr = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = servarrEnable;
        description = "Whether to enable Jellyseerr.";
      };
      firewall = {
        open = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to open the port for incoming connections inside Jellyseerr.";
        };
        port = lib.mkOption {
          type = lib.types.int;
          default = 5055;
          description = "The port used for connections inside Jellyseerr.";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf openFirewall {
      allowedTCPPorts = [ port ];
    };

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."jellyseerr" = {
      image = "fallenbagel/jellyseerr:latest";
      environment = {
        "LOG_LEVEL" = "debug";
        "TZ" = config.time.timeZone;
      };
      volumes = [
        "/containers/config/jellyseerr:/app/config:rw"
      ];
      ports = [
        "${portString}:5055/tcp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network-alias=jellyseerr"
        "--network=arr"
        "--network=exposed"
      ];
    };
    systemd.services."docker-jellyseerr" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "no";
      };
      after = [
        "docker-network-arr.service"
        "docker-network-exposed.service"
      ];
      requires = [
        "docker-network-arr.service"
        "docker-network-exposed.service"
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
