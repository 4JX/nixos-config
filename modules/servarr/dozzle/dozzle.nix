{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.dozzle;

  nobodyUser = builtins.toString config.users.users.nobody.uid;
  nogroupGroup = builtins.toString config.users.groups.nogroup.gid;
in
{
  config = lib.mkIf cfg.enable {
    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."dozzle" = {
      image = "amir20/dozzle:v8";
      environment = {
        "DOZZLE_REMOTE_HOST" = "tcp://dockerproxy-dozzle:2375";
      };
      ports = [
        "8090:8080/tcp"
      ];
      dependsOn = [
        "dockerproxy-dozzle"
      ];
      user = "${nobodyUser}:${nogroupGroup}";
      log-driver = "journald";
      extraOptions = [
        "--cap-drop=ALL"
        "--network-alias=dozzle"
        "--network=dozzle"
        "--network=socket-proxy-dozzle"
        "--security-opt=no-new-privileges"
      ];
    };
    systemd.services."docker-dozzle" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "no";
      };
      after = [
        "docker-network-dozzle.service"
        "docker-network-socket-proxy-dozzle.service"
      ];
      requires = [
        "docker-network-dozzle.service"
        "docker-network-socket-proxy-dozzle.service"
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
