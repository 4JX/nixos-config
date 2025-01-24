{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.swag-internal;
  servarrEnable = config.ncfg.servarr.enable;

  secretsFile.sopsFile = config.ncfg.servarr.secretsFolder + "/servarr.yaml";
in
{
  options.ncfg.servarr.swag-internal = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable;
      description = "Whether to enable SWAG-Internal.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.swag-internal-env = secretsFile;

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."swag-internal" = {
      image = "lscr.io/linuxserver/swag";
      environment = {
        "CERTPROVIDER" = "";
        "DNSPLUGIN" = "cloudflare";
        "DOCKER_MODS" = "linuxserver/mods:swag-auto-reload";
        "EXTRA_DOMAINS" = "";
        "ONLY_SUBDOMAINS" = "false";
        "PGID" = "1000";
        "PUID" = "1000";
        "STAGING" = "false";
        "SUBDOMAINS" = "wildcard";
        "TZ" = "Etc/UTC";
        "VALIDATION" = "dns";
      };
      environmentFiles = [
        config.sops.secrets.swag-internal-env.path
      ];
      volumes = [
        "/containers/config/swag-internal:/config:rw"
      ];
      ports = [
        "4433:443/tcp"
        "800:80/tcp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--network-alias=swag-internal"
        "--network=0wireguard"
        "--network=arr"
        "--network=authentik"
        "--network=dozzle"
        "--network=exposed"
        "--network=homarr"
        "--network=ldap"
        "--network=thelounge"
      ];
    };
    systemd.services."docker-swag-internal" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "no";
      };
      after = [
        "docker-network-0wireguard.service"
        "docker-network-arr.service"
        "docker-network-dozzle.service"
        "docker-network-exposed.service"
        "docker-network-homarr.service"
        "docker-network-thelounge.service"
      ];
      requires = [
        "docker-network-0wireguard.service"
        "docker-network-arr.service"
        "docker-network-dozzle.service"
        "docker-network-exposed.service"
        "docker-network-homarr.service"
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
