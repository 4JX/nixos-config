{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.cloudflared;
  servarrEnable = config.ncfg.servarr.enable;

  secretsFile.sopsFile = config.ncfg.servarr.secretsFolder + "/servarr.yaml";
in
{
  options = {
    ncfg.servarr.cloudflared.enable = lib.mkOption {
      type = lib.types.bool;
      default = false && servarrEnable;
      description = "Whether to enable CloudFlared.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.cloudflared-env = secretsFile;

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."cloudflared" = {
      image = "cloudflare/cloudflared";
      environmentFiles = [
        config.sops.secrets.cloudflared-env.path
      ];
      cmd = [ "tunnel" "run" ];
      log-driver = "journald";
      extraOptions = [
        "--network-alias=cloudflared-tunnel"
        "--network=exposed"
      ];
    };
    systemd.services."docker-cloudflared" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "no";
      };
      after = [
        "docker-network-exposed.service"
      ];
      requires = [
        "docker-network-exposed.service"
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
