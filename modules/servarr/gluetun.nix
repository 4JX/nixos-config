{ config, lib, ... }:

let
  cfg = config.ncfg.servarr.gluetun;
  servarrEnable = config.ncfg.servarr.enable;
in
{
  options.ncfg.servarr.gluetun.enable = lib.mkOption {
    type = lib.types.bool;
    default = servarrEnable;
    description = "Whether to enable gluetun.";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.gluetun-env = { };

    virtualisation.oci-containers.containers.gluetun = {
      image = "qmcgaw/gluetun";
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--device=/dev/net/tun"
      ];
      ports = [
        "8888:8888/tcp"
      ];
      volumes = [
        # "./riseup.ovpn:/gluetun/custom.conf:ro"
        # "./files/vpn-ca.pem:/files/vpn-ca.pem:ro"
        # "./files/cert.pem:/files/cert.pem:ro"
        # "./files/key.pem:/files/key.pem:ro"
      ];
      environmentFiles = [
        config.sops.secrets.gluetun-env.path
      ];
    };
  };
}
