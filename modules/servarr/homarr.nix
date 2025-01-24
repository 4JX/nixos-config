{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.homarr;
  servarrCfg = config.ncfg.servarr;
  servarrEnable = servarrCfg.enable;

  secretsFile.sopsFile = servarrCfg.secretsFolder + "/servarr.yaml";
in
{
  options = {
    ncfg.servarr.homarr.enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable;
      description = "Whether to enable Homarr.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.homarr-env = secretsFile;

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."homarr" = {
      image = "ghcr.io/homarr-labs/homarr:latest";
      environment = {
        "DISABLE_ANALYTICS" = "true";
      };
      environmentFiles = [
        config.sops.secrets.homarr-env.path
      ];
      volumes = [
        "/containers/config/homarr/appdata:/appdata:rw"
        "/var/run/docker.sock:/var/run/docker.sock:rw"
      ];
      ports = [
        "7575:7575/tcp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network-alias=homarr"
        "--network=arr"
      ];
    };
    systemd.services."docker-homarr" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "always";
        RestartMaxDelaySec = lib.mkOverride 90 "1m";
        RestartSec = lib.mkOverride 90 "100ms";
        RestartSteps = lib.mkOverride 90 9;
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
