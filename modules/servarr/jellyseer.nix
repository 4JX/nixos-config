{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.jellyseer;
  servarrEnable = config.ncfg.servarr.enable;

  openFirewall = cfg.firewall.open && cfg.firewall.port != null;
  port = cfg.firewall.port;
  portString = builtins.toString port;
in
{
  options = {
    ncfg.servarr.jellyseer = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = servarrEnable;
        description = "Whether to enable Jellyseer.";
      };
      firewall = {
        open = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to open the port for incoming connections inside Jellyseer.";
        };
        port = lib.mkOption {
          type = lib.types.int;
          default = 5055;
          description = "The port used for connections inside Jellyseer.";
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
        "/data/config/jellyseerr:/app/config:rw"
      ];
      ports = [
        "${portString}:5055/tcp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network-alias=jellyseerr"
        "--network=arr"
      ];
    };
    systemd.services."podman-jellyseerr" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "no";
      };
      after = [
        "podman-network-arr.service"
      ];
      requires = [
        "podman-network-arr.service"
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