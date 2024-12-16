# Auto-generated using compose2nix v0.3.2-pre.
{ pkgs, lib, ... }:

{
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."authentik-postgresql" = {
    image = "docker.io/library/postgres:16-alpine";
    volumes = [
      "/containers/authentik/postgresql:/var/lib/postgresql/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=pg_isready -d \${POSTGRES_DB} -U \${POSTGRES_USER}"
      "--health-interval=30s"
      "--health-retries=5"
      "--health-start-period=20s"
      "--health-timeout=5s"
      "--network-alias=postgresql"
      "--network=authentik"
    ];
  };
  systemd.services."docker-authentik-postgresql" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-authentik.service"
    ];
    requires = [
      "docker-network-authentik.service"
    ];
    partOf = [
      "docker-compose-servarr-root.target"
    ];
    wantedBy = [
      "docker-compose-servarr-root.target"
    ];
  };
  virtualisation.oci-containers.containers."authentik-redis" = {
    image = "docker.io/library/redis:alpine";
    volumes = [
      "/containers/authentik/redis:/data:rw"
    ];
    cmd = [ "--save" "60" "1" "--loglevel" "warning" ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=redis-cli ping | grep PONG"
      "--health-interval=30s"
      "--health-retries=5"
      "--health-start-period=20s"
      "--health-timeout=3s"
      "--network-alias=redis"
      "--network=authentik"
    ];
  };
  systemd.services."docker-authentik-redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-authentik.service"
    ];
    requires = [
      "docker-network-authentik.service"
    ];
    partOf = [
      "docker-compose-servarr-root.target"
    ];
    wantedBy = [
      "docker-compose-servarr-root.target"
    ];
  };
  virtualisation.oci-containers.containers."authentik-server" = {
    image = "ghcr.io/goauthentik/server:2024.10.5";
    environment = {
      "AUTHENTIK_DISABLE_STARTUP_ANALYTICS" = "true";
      "AUTHENTIK_ERROR_REPORTING__ENABLED" = "false";
      "AUTHENTIK_POSTGRESQL__HOST" = "postgresql";
      "AUTHENTIK_REDIS__HOST" = "redis";
    };
    volumes = [
      "/containers/authentik/authentik/custom-templates:/templates:rw"
      "/containers/authentik/authentik/media:/media:rw"
    ];
    ports = [
      "9000:9000/tcp"
      "9443:9443/tcp"
    ];
    cmd = [ "server" ];
    dependsOn = [
      "authentik-postgresql"
      "authentik-redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=server"
      "--network=authentik"
      "--network=exposed"
      "--network=ldap"
    ];
  };
  systemd.services."docker-authentik-server" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-authentik.service"
      "docker-network-ldap.service"
    ];
    requires = [
      "docker-network-authentik.service"
      "docker-network-ldap.service"
    ];
    partOf = [
      "docker-compose-servarr-root.target"
    ];
    wantedBy = [
      "docker-compose-servarr-root.target"
    ];
  };
  virtualisation.oci-containers.containers."authentik-worker" = {
    image = "ghcr.io/goauthentik/server:2024.10.5";
    environment = {
      "AUTHENTIK_DISABLE_STARTUP_ANALYTICS" = "true";
      "AUTHENTIK_ERROR_REPORTING__ENABLED" = "false";
      "AUTHENTIK_POSTGRESQL__HOST" = "postgresql";
      "AUTHENTIK_REDIS__HOST" = "redis";
    };
    volumes = [
      "/containers/authentik/authentik/certs:/certs:rw"
      "/containers/authentik/authentik/custom-templates:/templates:rw"
      "/containers/authentik/authentik/media:/media:rw"
      "/var/run/docker.sock:/var/run/docker.sock:rw"
    ];
    cmd = [ "worker" ];
    dependsOn = [
      "authentik-postgresql"
      "authentik-redis"
    ];
    user = "root";
    log-driver = "journald";
    extraOptions = [
      "--network-alias=worker"
      "--network=authentik"
    ];
  };
  systemd.services."docker-authentik-worker" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-authentik.service"
    ];
    requires = [
      "docker-network-authentik.service"
    ];
    partOf = [
      "docker-compose-servarr-root.target"
    ];
    wantedBy = [
      "docker-compose-servarr-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-authentik" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f authentik";
    };
    script = ''
      docker network inspect authentik || docker network create authentik
    '';
    partOf = [ "docker-compose-servarr-root.target" ];
    wantedBy = [ "docker-compose-servarr-root.target" ];
  };
  systemd.services."docker-network-ldap" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f ldap";
    };
    script = ''
      docker network inspect ldap || docker network create ldap
    '';
    partOf = [ "docker-compose-servarr-root.target" ];
    wantedBy = [ "docker-compose-servarr-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-servarr-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
