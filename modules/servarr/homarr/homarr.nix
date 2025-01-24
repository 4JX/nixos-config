{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.homarr;
  servarrCfg = config.ncfg.servarr;

  sopsFile = servarrCfg.secretsFolder + "/servarr.yaml";
  nobodyUser = config.users.users.nobody.uid;
  nogroupGroup = config.users.groups.nogroup.gid;
  nobodyUserString = builtins.toString nobodyUser;
  nogroupGroupString = builtins.toString nogroupGroup;
in
{
  config = lib.mkIf cfg.enable {
    sops.secrets.homarr-env = {
      inherit sopsFile;
      uid = nobodyUser;
      gid = nogroupGroup;
    };

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."homarr" = {
      image = "ghcr.io/homarr-labs/homarr:latest";
      environment = {
        "DISABLE_ANALYTICS" = "true";
        "DOCKER_HOSTNAMES" = "http://dockerproxy-homarr";
        "DOCKER_PORTS" = "2375";
        "PGID" = nobodyUserString;
        "PUID" = nogroupGroupString;
      };
      environmentFiles = [
        config.sops.secrets.homarr-env.path
      ];
      volumes = [
        "/containers/config/homarr/appdata:/appdata:rw"
      ];
      ports = [
        "7575:7575/tcp"
      ];
      # user = "${nobodyUserString}:${nogroupGroupString}";
      log-driver = "journald";
      extraOptions = [
        "--network-alias=homarr"
        "--network=homarr"
        "--network=socket-proxy-homarr"
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
        "docker-network-homarr.service"
        "docker-network-socket-proxy-homarr.service"
      ];
      requires = [
        "docker-network-homarr.service"
        "docker-network-socket-proxy-homarr.service"
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
