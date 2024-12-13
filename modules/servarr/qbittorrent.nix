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
      autoStart = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to start the container service automatically.";
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
    sops.secrets.qbit-wg0 = {
      sopsFile = config.ncfg.servarr.secretsFolder + "/qbit-wg0.conf";
      format = "binary";
    };

    # Open up a port for qbittorrent
    networking.firewall = lib.mkIf openFirewall {
      allowedTCPPorts = [ incomingPort ];
      allowedUDPPorts = [ incomingPort ];
    };

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."qbittorrent" = {
      # image = "ghcr.io/hotio/qbittorrent:release-5.0.2";
      image = "ghcr.io/hotio/qbittorrent:release-4.6.7";
      inherit (cfg) autoStart;
      environment = {
        "PGID" = "1000";
        "PRIVOXY_ENABLED" = "true";
        "PUID" = "1000";
        "TZ" = config.time.timeZone;
        "UMASK" = "002";
        "UNBOUND_ENABLED" = "false";
        "VPN_AUTO_PORT_FORWARD" = "true";
        "VPN_AUTO_PORT_FORWARD_TO_PORTS" = "";
        "VPN_CONF" = "wg0";
        "VPN_ENABLED" = "true";
        "VPN_EXPOSE_PORTS_ON_LAN" = "8080/tcp";
        "VPN_FIREWALL_TYPE" = "auto";
        "VPN_HEALTHCHECK_ENABLED" = "false";
        "VPN_KEEP_LOCAL_DNS" = "false";
        "VPN_LAN_LEAK_ENABLED" = "false";
        "VPN_LAN_NETWORK" = "192.168.1.0/24";
        "VPN_PROVIDER" = "proton";
        "WEBUI_PORTS" = "8080/tcp,8080/udp";
      };
      volumes = [
        "${config.sops.secrets.qbit-wg0.path}:/config/wireguard/wg0.conf:rw"
        "/containers/config/qbittorrent:/config:rw"
        "/containers/mediaserver/torrents:/data/torrents:rw"
      ];
      ports = [
        "8080:8080/tcp"
        "8118:8118/tcp"
      ]
      ++ lib.optionals openFirewall [
        "${incomingPortString}:${incomingPortString}/tcp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--dns=1.1.1.1"
        "--dns=9.9.9.9"
        "--network-alias=qbittorrent"
        "--network=arr"
        "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
        "--sysctl=net.ipv6.conf.all.disable_ipv6=1"
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
      # Avoid starting the service automatically unless explicitly requested
      # Override "virtualisation.oci-containers.containers.<name>.autoStart" which adds multi-user.target if true
      # TODO: lib.servarr.mkAutoStart (container-name)? Override container and service setting
      # https://github.com/NixOS/nixpkgs/blob/a3f9ad65a0bf298ed5847629a57808b97e6e8077/nixos/modules/virtualisation/oci-containers.nix#L246-L272
      wantedBy = lib.mkForce (
        if cfg.autoStart then [
          "podman-compose-servarr-root.target"
        ] else [ ]
      );
    };
  };
}
