{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.sonarr.tv-uhd;
  servarrEnable = config.ncfg.servarr.enable;
in
{
  options = {
    ncfg.servarr.sonarr.tv-uhd.enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable;
      description = "Whether to enable Sonarr (tv-uhd).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Settings:
    # https://trash-guides.info/Sonarr/Sonarr-Quality-Settings-File-Size/ -> http://localhost:8989/settings/quality (Fallback to min 5MiB/min)
    # https://trash-guides.info/Sonarr/Sonarr-recommended-naming-scheme/ -> http://localhost:8989/settings/mediamanagement (Jellyfin season folders)
    # https://trash-guides.info/Sonarr/sonarr-setup-quality-profiles/ + https://trash-guides.info/Sonarr/sonarr-setup-quality-profiles/#proper-and-repacks
    # https://trash-guides.info/Hardlinks/How-to-setup-for/ and https://trash-guides.info/Hardlinks/Examples/
    #! Disable "remove on download" for the downloaders, else chaos ensues with Hardlinks
    # To consider for movies: https://trash-guides.info/Misc/x265-4k/#golden-rule

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."sonarr-tv-uhd" = {
      image = "ghcr.io/hotio/sonarr";
      environment = {
        "PGID" = "1000";
        "PUID" = "1000";
        "TZ" = config.time.timeZone;
        "UMASK" = "002";
      };
      volumes = [
        "/containers/config/sonarr-tv-uhd:/config:rw"
        "/containers/mediaserver:/data:rw"
      ];
      ports = [
        "8990:8989/tcp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network-alias=sonarr-tv-uhd"
        "--network=arr"
      ];
    };
    systemd.services."docker-sonarr-tv-uhd" = {
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
