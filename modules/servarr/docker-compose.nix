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
  virtualisation.oci-containers.containers."cloudflared" = {
    image = "cloudflare/cloudflared";
    environment = {
      "TUNNEL_TOKEN" = "<token>";
    };
    cmd = [ "tunnel" "run" ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=cloudflared-tunnel"
      "--network=exposed"
    ];
  };
  systemd.services."docker-cloudflared" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "docker-network-exposed.service"
    ];
    requires = [
      "docker-network-exposed.service"
    ];
    partOf = [
      "docker-compose-servarr-root.target"
    ];
    wantedBy = [
      "docker-compose-servarr-root.target"
    ];
  };
  virtualisation.oci-containers.containers."cross-seed" = {
    image = "ghcr.io/cross-seed/cross-seed:6";
    volumes = [
      "/CHANGEME:/config/config.js:rw"
      "/containers/config/cross-seed:/config:rw"
      "/containers/config/qbittorrent/data/BT_backup:/torrents:ro"
      "/containers/mediaserver/torrents:/data/torrents:rw"
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
    wantedBy = [
      "docker-compose-servarr-root.target"
    ];
  };
  virtualisation.oci-containers.containers."dozzle" = {
    image = "amir20/dozzle:latest";
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock:rw"
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
  systemd.services."docker-dozzle" = {
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
  systemd.services."docker-flaresolverr" = {
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
  systemd.services."docker-gluetun" = {
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
  virtualisation.oci-containers.containers."homarr" = {
    image = "ghcr.io/ajnart/homarr:latest";
    environment = {
      "DISABLE_ANALYTICS" = "true";
    };
    volumes = [
      "/containers/config/homarr/configs:/app/containers/configs:rw"
      "/containers/config/homarr/data:/data:rw"
      "/containers/config/homarr/icons:/app/public/icons:rw"
      "/var/run/docker.sock:/var/run/docker.sock:rw"
    ];
    ports = [
      "7575:7575/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=homarr"
      "--network=arr"
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
  virtualisation.oci-containers.containers."jellyfin" = {
    image = "ghcr.io/hotio/jellyfin";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "Etc/UTC";
      "UMASK" = "002";
    };
    volumes = [
      "/containers/config/jellyfin:/config:rw"
      "/containers/mediaserver/media:/data/media:rw"
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
      "--network=exposed"
      "--network=ldap"
    ];
  };
  systemd.services."docker-jellyfin" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "docker-network-arr.service"
      "docker-network-exposed.service"
    ];
    requires = [
      "docker-network-arr.service"
      "docker-network-exposed.service"
    ];
    partOf = [
      "docker-compose-servarr-root.target"
    ];
    wantedBy = [
      "docker-compose-servarr-root.target"
    ];
  };
  virtualisation.oci-containers.containers."jellyseerr" = {
    image = "fallenbagel/jellyseerr:latest";
    environment = {
      "LOG_LEVEL" = "debug";
      "TZ" = "Etc/UTC";
    };
    volumes = [
      "/containers/config/jellyseerr:/app/config:rw"
    ];
    ports = [
      "5055:5055/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=jellyseerr"
      "--network=arr"
      "--network=exposed"
    ];
  };
  systemd.services."docker-jellyseerr" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "docker-network-arr.service"
      "docker-network-exposed.service"
    ];
    requires = [
      "docker-network-arr.service"
      "docker-network-exposed.service"
    ];
    partOf = [
      "docker-compose-servarr-root.target"
    ];
    wantedBy = [
      "docker-compose-servarr-root.target"
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
      "/containers/config/prowlarr:/config:rw"
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
  systemd.services."docker-prowlarr" = {
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
  systemd.services."docker-qbit_manage" = {
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
      "/containers/config/qbittorrent:/config:rw"
      "/containers/mediaserver/torrents:/data/torrents:rw"
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
  systemd.services."docker-qbittorrent" = {
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
  virtualisation.oci-containers.containers."radarr-movies-hd" = {
    image = "ghcr.io/hotio/radarr";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "Etc/UTC";
      "UMASK" = "002";
    };
    volumes = [
      "/containers/config/radarr-movies-hd:/config:rw"
      "/containers/mediaserver:/data:rw"
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
  systemd.services."docker-radarr-movies-hd" = {
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
  virtualisation.oci-containers.containers."radarr-movies-uhd" = {
    image = "ghcr.io/hotio/radarr";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "Etc/UTC";
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
  virtualisation.oci-containers.containers."recyclarr" = {
    image = "ghcr.io/recyclarr/recyclarr";
    environment = {
      "TZ" = "Etc/UTC";
    };
    volumes = [
      "/CHANGEME:/config/recyclarr.yml:rw"
      "/CHANGEME2:/config/secrets.yml:rw"
      "/containers/config/recyclarr:/config:rw"
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
  systemd.services."docker-recyclarr" = {
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
  virtualisation.oci-containers.containers."sonarr-anime" = {
    image = "ghcr.io/hotio/sonarr";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "Etc/UTC";
      "UMASK" = "002";
    };
    volumes = [
      "/containers/config/sonarr-anime:/config:rw"
      "/containers/mediaserver:/data:rw"
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
  systemd.services."docker-sonarr-anime" = {
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
  virtualisation.oci-containers.containers."sonarr-tv-hd" = {
    image = "ghcr.io/hotio/sonarr";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "Etc/UTC";
      "UMASK" = "002";
    };
    volumes = [
      "/containers/config/sonarr-tv-hd:/config:rw"
      "/containers/mediaserver:/data:rw"
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
  systemd.services."docker-sonarr-tv-hd" = {
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
  virtualisation.oci-containers.containers."swag" = {
    image = "lscr.io/linuxserver/swag";
    environment = {
      "CERTPROVIDER" = "";
      "DNSPLUGIN" = "cloudflare";
      "DOCKER_MODS" = "linuxserver/mods:swag-cloudflare-real-ip|linuxserver/mods:swag-auto-reload";
      "EXTRA_DOMAINS" = "";
      "ONLY_SUBDOMAINS" = "false";
      "PGID" = "1000";
      "PUID" = "1000";
      "STAGING" = "false";
      "SUBDOMAINS" = "wildcard";
      "TZ" = "Etc/UTC";
      "VALIDATION" = "dns";
    };
    volumes = [
      "/containers/config/swag:/config:rw"
    ];
    ports = [
      "443:443/tcp"
      "80:80/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--network-alias=swag"
      "--network=exposed"
    ];
  };
  systemd.services."docker-swag" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "docker-network-exposed.service"
    ];
    requires = [
      "docker-network-exposed.service"
    ];
    partOf = [
      "docker-compose-servarr-root.target"
    ];
    wantedBy = [
      "docker-compose-servarr-root.target"
    ];
  };
  virtualisation.oci-containers.containers."thelounge" = {
    image = "ghcr.io/thelounge/thelounge:latest";
    volumes = [
      "/containers/config/thelounge:/var/opt/thelounge:rw"
    ];
    ports = [
      "9010:9000/tcp"
    ];
    user = "1000:1000";
    log-driver = "journald";
    extraOptions = [
      "--network-alias=thelounge"
      "--network=thelounge"
    ];
  };
  systemd.services."docker-thelounge" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "docker-network-thelounge.service"
    ];
    requires = [
      "docker-network-thelounge.service"
    ];
    partOf = [
      "docker-compose-servarr-root.target"
    ];
    wantedBy = [
      "docker-compose-servarr-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-arr" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f arr";
    };
    script = ''
      docker network inspect arr || docker network create arr
    '';
    partOf = [ "docker-compose-servarr-root.target" ];
    wantedBy = [ "docker-compose-servarr-root.target" ];
  };
  systemd.services."docker-network-exposed" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f exposed";
    };
    script = ''
      docker network inspect exposed || docker network create exposed
    '';
    partOf = [ "docker-compose-servarr-root.target" ];
    wantedBy = [ "docker-compose-servarr-root.target" ];
  };
  systemd.services."docker-network-thelounge" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f thelounge";
    };
    script = ''
      docker network inspect thelounge || docker network create thelounge
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
