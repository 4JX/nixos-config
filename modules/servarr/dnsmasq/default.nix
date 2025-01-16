{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.dnsmasq;
  servarrEnable = config.ncfg.servarr.enable;

  configFile = ./dnsmasq.conf;
in
{
  options = {
    ncfg.servarr.dnsmasq.enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable;
      description = "Whether to enable dnsmasq.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers."dnsmasq" = {
      image = "4km3/dnsmasq:2.90-r3";
      volumes = [
        "${configFile}:/etc/dnsmasq.conf:rw"
      ];
      ports = [
        "5300:53/tcp"
        "5300:53/udp"
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
