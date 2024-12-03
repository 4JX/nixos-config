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
  virtualisation.oci-containers.containers."jellyfin" = {
    image = "ghcr.io/hotio/jellyfin";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "Etc/UTC";
      "UMASK" = "002";
    };
    volumes = [
      "/data/config/jellyfin:/config:rw"
      "/data/media:/data/media:rw"
    ];
    ports = [
      "8096:8096/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--device=/dev/dri:/dev/dri:rwm"
      "--device=nvidia.com/gpu=all"
      "--network-alias=jellyfin"
      "--network=arr"
    ];
  };
  systemd.services."podman-jellyfin" = {
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
  virtualisation.oci-containers.containers."jellyseerr" = {
    image = "fallenbagel/jellyseerr:latest";
    environment = {
      "LOG_LEVEL" = "debug";
      "TZ" = "Etc/UTC";
    };
    volumes = [
      "/data/config/jellyseerr:/app/config:rw"
    ];
    ports = [
      "5055:5055/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=jellyseerr"
      "--network=arr"
    ];
  };
  systemd.services."podman-jellyseerr" = {
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
  virtualisation.oci-containers.containers."qbit_manage" = {
    image = "ghcr.io/stuffanthings/qbit_manage:latest";
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
      "/CHANGEME:/config/config.yml:rw"
      "/data/config/qbit_manage/:/config:rw"
      "/data/config/qbittorrent:/qbittorrent:ro"
      "/data/torrents/:/data/torrents:rw"
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
    wantedBy = [
      "podman-compose-servarr-root.target"
    ];
  };
  virtualisation.oci-containers.containers."qbittorrent" = {
    image = "ghcr.io/hotio/qbittorrent:release-4.6.7";
    environment = {
      "PGID" = "1000";
      "PRIVOXY_ENABLED" = "true";
      "PUID" = "1000";
      "TZ" = "Etc/UTC";
      "UMASK" = "002";
      "UNBOUND_ENABLED" = "false";
      "VPN_AUTO_PORT_FORWARD" = "true";
      "VPN_AUTO_PORT_FORWARD_TO_PORTS" = "";
      "VPN_CONF" = "wg0";
      "VPN_ENABLED" = "true";
      "VPN_EXPOSE_PORTS_ON_LAN" = "8080/tcp";
      "VPN_FIREWALL_TYPE" = "auto";
      "VPN_HEALTHCHECK_ENABLED" = "false";
      "VPN_KEEP_LOCAL_DNS" = "false";
      "VPN_LAN_LEAK_ENABLED" = "false";
      "VPN_LAN_NETWORK" = "192.168.1.0/24";
      "VPN_PROVIDER" = "proton";
      "WEBUI_PORTS" = "8080/tcp,8080/udp";
    };
    volumes = [
      "/CHANGEME:/config/wireguard/wg0.conf:rw"
      "/data/config/qbittorrent:/config:rw"
      "/data/torrents:/data/torrents:rw"
    ];
    ports = [
      "8080:8080/tcp"
      "8118:8118/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--dns=1.1.1.1"
      "--dns=9.9.9.9"
      "--network-alias=qbittorrent"
      "--network=arr"
      "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
      "--sysctl=net.ipv6.conf.all.disable_ipv6=1"
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
      "sonarr-tv-hd"
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
  virtualisation.oci-containers.containers."sonarr-tv-hd" = {
    image = "ghcr.io/hotio/sonarr";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "Etc/UTC";
      "UMASK" = "002";
    };
    volumes = [
      "/data:/data:rw"
      "/data/config/sonarr-tv-hd:/config:rw"
    ];
    ports = [
      "8989:8989/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=sonarr-tv-hd"
      "--network=arr"
    ];
  };
  systemd.services."podman-sonarr-tv-hd" = {
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
