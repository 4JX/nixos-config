{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.dnsmasq;
  servarrEnable = config.ncfg.servarr.enable;

  configFile = ./dnsmasq.conf;
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
        "${configFile}:/etc/dnsmasq.conf:rw"
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
        "--network=arr"
        "--network=authentik"
        "--network=exposed"
        "--network=ldap"
        "--network=thelounge"
      ];
    };
    systemd.services."docker-dnsmasq" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "no";
      };
      after = [
        "docker-network-arr.service"
        "docker-network-exposed.service"
        "docker-network-thelounge.service"
      ];
      requires = [
        "docker-network-arr.service"
        "docker-network-exposed.service"
        "docker-network-thelounge.service"
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
