{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.qbit_manage;
  servarrCfg = config.ncfg.servarr;
  servarrEnable = servarrCfg.enable;
  qbitCfg = servarrCfg.qbittorrent;

  manageYaml = config.sops.secrets.qbit_manage.path;
in
{
  options = {
    ncfg.servarr.qbit_manage.enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable;
      description = "Whether to enable qbit_manage.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.qbit_manage = {
      sopsFile = servarrCfg.secretsFolder + "/qbit_manage.yml";
      # Serve the whole YAML file
      key = "";
    };

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."qbit_manage" = {
      image = "ghcr.io/stuffanthings/qbit_manage:latest";
      inherit (qbitCfg) autoStart;
      environment = {
        "QBT_CAT_UPDATE" = "false";
        "QBT_CONFIG" = "config.yml";
        "QBT_CROSS_SEED" = "false";
        "QBT_DIVIDER" = "=";
        "QBT_DRY_RUN" = "false";
        "QBT_LOGFILE" = "activity.log";
        "QBT_LOG_LEVEL" = "INFO";
        "QBT_RECHECK" = "false";
        "QBT_REM_ORPHANED" = "false";
        "QBT_REM_UNREGISTERED" = "false";
        "QBT_RUN" = "false";
        "QBT_SCHEDULE" = "1440";
        "QBT_SHARE_LIMITS" = "false";
        "QBT_SKIP_CLEANUP" = "false";
        "QBT_TAG_NOHARDLINKS" = "false";
        "QBT_TAG_TRACKER_ERROR" = "false";
        "QBT_TAG_UPDATE" = "false";
        "QBT_WIDTH" = "100";
      };
      volumes = [
        "${manageYaml}:/config/config.yml:rw"
        "/containers/config/qbit_manage/:/config:rw"
        "/containers/config/qbittorrent:/qbittorrent:ro"
        "/containers/mediaserver/torrents/:/data/torrents:rw"
      ];
      dependsOn = [
        "qbittorrent"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network-alias=qbit_manage"
        "--network=arr"
      ];
    };
    systemd.services."podman-qbit_manage" = {
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
      # Do not start qbit_manage if qbittorrent is not set to autoStart as well
      # This avoids qbittorrent being started by proxy due to qbit_manage's wantedBy+dependsOn
      wantedBy = lib.mkForce (
        if qbitCfg.autoStart then [
          "podman-compose-servarr-root.target"
        ] else [ ]
      );
    };
  };
} 
