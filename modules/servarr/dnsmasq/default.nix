{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.dnsmasq;
  servarrEnable = config.ncfg.servarr.enable;

  wgPortString = builtins.toString cfg.wgPort;
in
{
  options = {
    ncfg.servarr.dnsmasq = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = servarrEnable;
        description = "Whether to enable dnsmasq.";
      };
      wgPort = lib.mkOption {
        type = lib.types.int;
        default = 54000;
        description = "The port used for connections inside wg-easy.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = [ cfg.wgPort ];

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."dnsmasq" = {
      image = "4km3/dnsmasq:2.90-r3";
      volumes = [
        "/containers/config/dnsmasq/dnsmasq.conf:/etc/dnsmasq.conf:ro"
      ];
      ports = [
        "5300:53/tcp"
        "5300:53/udp"
        "${wgPortString}:51820/udp"
        "54001:51821/tcp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--network-alias=dnsmasq"
        "--network=0wireguard"
      ];
    };
    systemd.services."docker-dnsmasq" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "no";
      };
      after = [
        "docker-network-0wireguard.service"
      ];
      requires = [
        "docker-network-0wireguard.service"
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
