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
        "--network=arr"
      ];
    };
    systemd.services."podman-cloudflared" = {
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
