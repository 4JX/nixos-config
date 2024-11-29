{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.jellyfin;
  servarrEnable = config.ncfg.servarr.enable;
  containerToolkitEnable = config.ncfg.servarr.nvidia-container-toolkit.enable;

  openFirewall = cfg.firewall.open && cfg.firewall.port != null;
  port = cfg.firewall.port;
  portString = builtins.toString port;
in
{
  options = {
    ncfg.servarr.jellyfin = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = servarrEnable;
        description = "Whether to enable Jellyfin.";
      };
      firewall = {
        open = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to open the port for incoming connections inside Jellyfin.";
        };
        port = lib.mkOption {
          type = lib.types.int;
          default = 8096;
          description = "The port used for connections inside Jellyfin.";
        };
      };

    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf openFirewall {
      allowedTCPPorts = [ port ];
    };

    virtualisation.oci-containers.containers."jellyfin" = {
      image = "ghcr.io/hotio/jellyfin";
      environment = {
        "PGID" = "1000";
        "PUID" = "1000";
        "TZ" = config.time.timeZone;
        "UMASK" = "002";
      };
      volumes = [
        "/data/media:/data/media:rw"
        "/data/config/jellyfin:/config:rw"
      ];
      ports = [
        "${portString}:8096/tcp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--device=/dev/dri:/dev/dri:rwm"
        "--network-alias=jellyfin"
        "--network=arr"
      ] ++ lib.optionals containerToolkitEnable [
        "--device=nvidia.com/gpu=all"
      ];
    };
    systemd.services."podman-jellyfin" = {
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
