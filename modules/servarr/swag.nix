{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.swag;
  servarrEnable = config.ncfg.servarr.enable;

  secretsFile.sopsFile = config.ncfg.servarr.secretsFolder + "/servarr.yaml";
in
{
  options.ncfg.servarr.swag = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false && servarrEnable;
      description = "Whether to enable SWAG.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.swag-env = secretsFile;

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."swag" = {
      image = "lscr.io/linuxserver/swag";
      environment = {
        "CERTPROVIDER" = "";
        "DNSPLUGIN" = "cloudflare";
        "DOCKER_MODS" = "linuxserver/mods:swag-cloudflare-real-ip|linuxserver/mods:swag-auto-reload";
        "EXTRA_DOMAINS" = "";
        "ONLY_SUBDOMAINS" = "false";
        "PGID" = "1000";
        "PUID" = "1000";
        "STAGING" = "false";
        "SUBDOMAINS" = "wildcard";
        "TZ" = config.time.timeZone;
        "VALIDATION" = "dns";
      };
      environmentFiles = [
        config.sops.secrets.swag-env.path
      ];
      volumes = [
        "/containers/config/swag:/config:rw"
      ];
      ports = [
        "443:443/tcp"
        "80:80/tcp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--network-alias=swag"
        "--network=arr"
      ];
    };
  };
}
