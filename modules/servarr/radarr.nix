{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.radarr;
  servarrEnable = config.ncfg.servarr.enable;
in
{
  options = {
    ncfg.servarr.radarr.enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable && false; # Disabled for now
      description = "Whether to enable Radarr.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Settings:
    # https://trash-guides.info/Radarr/Radarr-Quality-Settings-File-Size/ -> http://localhost:7878/settings/quality (Fallback to min 5MiB/min)
    # https://trash-guides.info/Radarr/Radarr-recommended-naming-scheme/ -> http://localhost:7878/settings/mediamanagement (Jellyfin season folders)
    # https://trash-guides.info/Radarr/radarr-setup-quality-profiles/ + https://trash-guides.info/Radarr/radarr-setup-quality-profiles/#proper-and-repacks
    # https://trash-guides.info/Hardlinks/How-to-setup-for/ and https://trash-guides.info/Hardlinks/Examples/
    # To consider for movies: https://trash-guides.info/Misc/x265-4k/#golden-rule

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."radarr" = {
      image = "ghcr.io/hotio/radarr";
      environment = {
        "PGID" = "1000";
        "PUID" = "1000";
        "TZ" = "Etc/UTC";
        "UMASK" = "002";
      };
      volumes = [
        "/data:/data:rw"
        "/data/config/radarr:/config:rw"
      ];
      ports = [
        "7878:7878/tcp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network-alias=radarr"
        "--network=arr"
      ];
    };
    systemd.services."podman-radarr" = {
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
