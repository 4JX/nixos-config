{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.cross-seed;
  servarrEnable = config.ncfg.servarr.enable;

  qbitCfg = config.ncfg.servarr.qbittorrent;
in
{
  options.ncfg.servarr.cross-seed = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable;
      description = "Whether to enable cross-seed.";
    };
    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to start cross-seed automatically.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.cross-seed-config = {
      sopsFile = config.ncfg.servarr.secretsFolder + "/cross-seed-config.js";
      format = "binary";
      # This isn't that pretty of a solution, but it works
      # TODO: Dedicated docker user+group?
      uid = 1000;
      gid = 1000;
    };
    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."cross-seed" = {
      image = "ghcr.io/cross-seed/cross-seed:6";
      inherit (qbitCfg) autoStart;
      volumes = [
        "/containers/config/cross-seed:/config:rw"
        "${config.sops.secrets.cross-seed-config.path}:/config/config.js:ro"
        "/containers/config/qbittorrent/data/BT_backup:/torrents:ro"
        "/containers/mediaserver/torrents:/data/torrents:rw"
        "/containers/mediaserver/torrents/cross-seed/output:/output:rw"
      ];
      ports = [
        "2468:2468/tcp"
      ];
      cmd = [ "daemon" ];
      user = "1000:1000";
      log-driver = "journald";
      extraOptions = [
        "--network-alias=cross-seed"
        "--network=arr"
      ];
    };
    systemd.services."docker-cross-seed" = {
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
      # Do not start cross-seed if qbittorrent is not set to autoStart as well
      # This avoids qbittorrent being started by proxy due to cross-seed's wantedBy+dependsOn
      wantedBy = lib.mkForce (
        if qbitCfg.autoStart then [
          "docker-compose-servarr-root.target"
        ] else [ ]
      );
    };
  };
}
