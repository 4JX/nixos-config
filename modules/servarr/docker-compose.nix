# Auto-generated using compose2nix v0.3.2-pre.
{ pkgs, lib, ... }:

{
  # Runtime
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
    };
  };

  # Enable container name DNS for non-default Podman networks.
  # https://github.com/NixOS/nixpkgs/issues/226365
  networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 ];

  virtualisation.oci-containers.backend = "podman";

  # Containers
  virtualisation.oci-containers.containers."dozzle" = {
    image = "amir20/dozzle:latest";
    volumes = [
      "/run/podman/podman.sock:/var/run/docker.sock:rw"
    ];
    ports = [
      "8090:8080/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=dozzle"
      "--network=arr"
    ];
  };
  systemd.services."podman-dozzle" = {
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
  virtualisation.oci-containers.containers."flaresolverr" = {
    image = "ghcr.io/flaresolverr/flaresolverr:latest";
    environment = {
      "CAPTCHA_SOLVER" = "none";
      "LOG_HTML" = "false";
      "LOG_LEVEL" = "info";
      "TZ" = "Etc/UTC";
    };
    ports = [
      "8191:8191/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=flaresolverr"
      "--network=arr"
    ];
  };
  systemd.services."podman-flaresolverr" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
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
  virtualisation.oci-containers.containers."gluetun" = {
    image = "qmcgaw/gluetun";
    ports = [
      "8888:8888/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--device=/dev/net/tun:/dev/net/tun:rwm"
      "--network-alias=gluetun"
      "--network=arr"
    ];
  };
  systemd.services."podman-gluetun" = {
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
  virtualisation.oci-containers.containers."prowlarr" = {
    image = "ghcr.io/hotio/prowlarr";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "Etc/UTC";
      "UMASK" = "002";
    };
    volumes = [
      "/data/config/prowlarr:/config:rw"
    ];
    ports = [
      "9696:9696/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=prowlarr"
      "--network=arr"
    ];
  };
  systemd.services."podman-prowlarr" = {
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
  virtualisation.oci-containers.containers."qbittorrent" = {
    image = "ghcr.io/hotio/qbittorrent";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "Etc/UTC";
      "UMASK" = "002";
      "WEBUI_PORTS" = "8080/tcp,8080/udp";
    };
    volumes = [
      "/data/config/qBit:/config:rw"
      "/data/torrents:/data/torrents:rw"
    ];
    ports = [
      "8080:8080/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=qbittorrent"
      "--network=arr"
    ];
  };
  systemd.services."podman-qbittorrent" = {
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
  virtualisation.oci-containers.containers."radarr-movies-hd" = {
    image = "ghcr.io/hotio/radarr";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "Etc/UTC";
      "UMASK" = "002";
    };
    volumes = [
      "/data:/data:rw"
      "/data/config/radarr-movies-hd:/config:rw"
    ];
    ports = [
      "7878:7878/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=radarr-movies-hd"
      "--network=arr"
    ];
  };
  systemd.services."podman-radarr-movies-hd" = {
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
  virtualisation.oci-containers.containers."recyclarr" = {
    image = "ghcr.io/recyclarr/recyclarr";
    environment = {
      "TZ" = "Etc/UTC";
    };
    volumes = [
      "/CHANGEME:/config/recyclarr.yml:rw"
      "/CHANGEME2:/config/secrets.yml:rw"
      "/data/config/recyclarr:/config:rw"
    ];
    dependsOn = [
      "radarr-movies-hd"
      "sonarr-anime"
    ];
    user = "nobody:nogroup";
    log-driver = "journald";
    extraOptions = [
      "--network-alias=recyclarr"
      "--network=arr"
    ];
  };
  systemd.services."podman-recyclarr" = {
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
  virtualisation.oci-containers.containers."sonarr-anime" = {
    image = "ghcr.io/hotio/sonarr";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "Etc/UTC";
      "UMASK" = "002";
    };
    volumes = [
      "/data:/data:rw"
      "/data/config/sonarr-anime:/config:rw"
    ];
    ports = [
      "8990:8989/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=sonarr-anime"
      "--network=arr"
    ];
  };
  systemd.services."podman-sonarr-anime" = {
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

  # Networks
  systemd.services."podman-network-arr" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f arr";
    };
    script = ''
      podman network inspect arr || podman network create arr
    '';
    partOf = [ "podman-compose-servarr-root.target" ];
    wantedBy = [ "podman-compose-servarr-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-servarr-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
