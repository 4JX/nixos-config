{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.dozzle;
  servarrEnable = config.ncfg.servarr.enable;
in
{
  options = {
    ncfg.servarr.dozzle.enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable;
      description = "Whether to enable Dozzle.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."dozzle" = {
      image = "amir20/dozzle:latest";
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:rw" # TODO: Infer location from enabled container management system?
      ];
      ports = [
        "8090:8080/tcp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network-alias=dozzle"
        "--network=arr"
      ];
    };
    systemd.services."docker-dozzle" = {
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
