{ config, lib, ... }:

let
  cfg = config.ncfg.servarr.gluetun;
  servarrCfg = config.ncfg.servarr;
  servarrEnable = servarrCfg.enable;
  secretsFile.sopsFile = servarrCfg.secretsFolder + "/servarr.yaml";
in
{
  options.ncfg.servarr.gluetun.enable = lib.mkOption {
    type = lib.types.bool;
    default = servarrEnable;
    description = "Whether to enable gluetun.";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.gluetun-env = secretsFile;

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."gluetun" = {
      image = "qmcgaw/gluetun";
      environmentFiles = [
        config.sops.secrets.gluetun-env.path
      ];
      ports = [
        "8888:8888/tcp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--device=/dev/net/tun:/dev/net/tun:rwm"
        "--network-alias=gluetun"
        "--network=arr"
      ];
    };
    systemd.services."docker-gluetun" = {
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
      wantedBy = [
        "docker-compose-servarr-root.target"
      ];
    };
  };
}
