{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.authentik.worker;

  nobodyUser = builtins.toString config.users.users.nobody.uid;
  dockerGroup = builtins.toString config.users.groups.docker.gid;
in
{
  config = lib.mkIf cfg.enable {
    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."dockerproxy-authentik-worker" = {
      image = "wollomatic/socket-proxy:1";
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
      cmd = [ "-loglevel=info" "-allowfrom=authentik-worker" "-listenip=0.0.0.0" "-allowGET=/(version|v1\\.[0-9]{1,2}/(info|containers/(json|[^/]+/json)|images/.*))" "-allowPOST=/v1\\.[0-9]{1,2}/(images/create|containers/(create|([a-f0-9]{12}|[a-f0-9]{64})/(start|kill)))" "-allowDELETE=/v1\\.[0-9]{1,2}/containers/([a-f0-9]{12}|[a-f0-9]{64})" "-watchdoginterval=300" "-stoponwatchdog" "-shutdowngracetime=10" ];
      user = "${nobodyUser}:${dockerGroup}";
      log-driver = "journald";
      extraOptions = [
        "--cap-drop=ALL"
        "--network-alias=dockerproxy-authentik-worker"
        "--network=socket-proxy-authentik-worker"
        "--security-opt=no-new-privileges"
      ];
    };
    systemd.services."docker-dockerproxy-authentik-worker" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "always";
        RestartMaxDelaySec = lib.mkOverride 90 "1m";
        RestartSec = lib.mkOverride 90 "100ms";
        RestartSteps = lib.mkOverride 90 9;
      };
      after = [
        "docker-network-socket-proxy-authentik-worker.service"
      ];
      requires = [
        "docker-network-socket-proxy-authentik-worker.service"
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
