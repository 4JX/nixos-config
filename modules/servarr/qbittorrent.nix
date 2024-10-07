{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.qbittorrent;
  servarrEnable = config.ncfg.servarr.enable;
  openFirewall = cfg.firewall.open && cfg.firewall.incomingPort != null;
  incomingPort = cfg.firewall.incomingPort;
  incomingPortString = builtins.toString incomingPort;
in
{
  options = {
    ncfg.servarr.qbittorrent = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = servarrEnable;
        description = "Whether to enable QBit.";
      };
      firewall = {
        open = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to open the port for incoming connections inside qBit.";
        };
        # lib.types.strMatching "([0-9]{1,5}):([0-9]{1,5})/?(tcp|udp|sctp)?"
        incomingPort = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
          description = "The port used for incoming connections inside qBit.";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Open up a port for qbittorrent
    networking.firewall = lib.mkIf (openFirewall) {
      allowedTCPPorts = [ incomingPort ];
      allowedUDPPorts = [ incomingPort ];
    };

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."qbittorrent" = {
      image = "ghcr.io/hotio/qbittorrent";
      environment = {
        "PGID" = "1000";
        "PUID" = "1000";
        "TZ" = "Etc/UTC";
        "UMASK" = "002";
        "WEBUI_PORTS" = "8080/tcp,8080/udp";
      };
      volumes = [
        "/data/config/qBit:/config:rw"
        "/data/torrents:/data/torrents:rw"
      ];
      ports = [
        "8080:8080/tcp"
      ]
      ++ lib.optionals openFirewall [
        "${incomingPortString}:${incomingPortString}/tcp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network-alias=qbittorrent"
        "--network=arr"
      ];
    };
    systemd.services."podman-qbittorrent" = {
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
