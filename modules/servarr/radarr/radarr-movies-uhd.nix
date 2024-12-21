{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.radarr.movies-uhd;
  servarrEnable = config.ncfg.servarr.enable;
in
{
  options = {
    ncfg.servarr.radarr.movies-uhd.enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable;
      description = "Whether to enable Radarr (movies-uhd).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Settings:
    # https://trash-guides.info/Radarr/Radarr-Quality-Settings-File-Size/ -> http://localhost:7878/settings/quality (Fallback to min 5MiB/min)
    # https://trash-guides.info/Radarr/Radarr-recommended-naming-scheme/ -> http://localhost:7878/settings/mediamanagement (Jellyfin season folders)
    # https://trash-guides.info/Radarr/radarr-setup-quality-profiles/ + https://trash-guides.info/Radarr/radarr-setup-quality-profiles/#proper-and-repacks
    # https://trash-guides.info/Hardlinks/How-to-setup-for/ and https://trash-guides.info/Hardlinks/Examples/
    #! Disable "remove on download" for the downloaders, else chaos ensues with Hardlinks
    # To consider for movies: https://trash-guides.info/Misc/x265-4k/#golden-rule

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."radarr-movies-uhd" = {
      image = "ghcr.io/hotio/radarr";
      environment = {
        "PGID" = "1000";
        "PUID" = "1000";
        "TZ" = config.time.timeZone;
        "UMASK" = "002";
      };
      volumes = [
        "/containers/config/radarr-movies-uhd:/config:rw"
        "/containers/mediaserver:/data:rw"
      ];
      ports = [
        "7879:7878/tcp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network-alias=radarr-movies-uhd"
        "--network=arr"
      ];
    };
    systemd.services."docker-radarr-movies-uhd" = {
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
