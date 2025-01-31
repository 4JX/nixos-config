# Auto-generated using compose2nix v0.3.1.
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
  virtualisation.oci-containers.containers."dnsmasq" = {
    image = "4km3/dnsmasq:2.90-r3";
    volumes = [
      "/containers/config/dnsmasq/dnsmasq.conf:/etc/dnsmasq.conf:ro"
    ];
    ports = [
      "5300:53/tcp"
      "5300:53/udp"
      "54000:51820/udp"
      "54001:51821/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--network-alias=dnsmasq"
      "--network=0wireguard"
    ];
  };
  systemd.services."docker-dnsmasq" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "docker-network-0wireguard.service"
    ];
    requires = [
      "docker-network-0wireguard.service"
    ];
    partOf = [
      "docker-compose-servarr-root.target"
    ];
    wantedBy = [
      "docker-compose-servarr-root.target"
    ];
  };
  virtualisation.oci-containers.containers."dockerproxy-dozzle" = {
    image = "wollomatic/socket-proxy:1";
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock:ro"
    ];
    cmd = [ "-loglevel=info" "-allowfrom=dozzle" "-listenip=0.0.0.0" "-allowGET=/v1\\.[0-9]{1,2}/(_ping|info|events|containers/(json|([a-f0-9]{12}|[a-f0-9]{64})/(json|stats|logs)))" "-allowHEAD=/_ping" "-watchdoginterval=300" "-stoponwatchdog" "-shutdowngracetime=10" ];
    user = "nobody:docker";
    log-driver = "journald";
    extraOptions = [
      "--cap-drop=ALL"
      "--network-alias=dockerproxy-dozzle"
      "--network=socket-proxy-dozzle"
      "--security-opt=no-new-privileges"
    ];
  };
  systemd.services."docker-dockerproxy-dozzle" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-socket-proxy-dozzle.service"
    ];
    requires = [
      "docker-network-socket-proxy-dozzle.service"
    ];
    partOf = [
      "docker-compose-servarr-root.target"
    ];
    wantedBy = [
      "docker-compose-servarr-root.target"
    ];
  };
  virtualisation.oci-containers.containers."dockerproxy-homarr" = {
    image = "wollomatic/socket-proxy:1";
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock:ro"
    ];
    cmd = [ "-loglevel=info" "-allowfrom=homarr" "-listenip=0.0.0.0" "-allowGET=/containers/(json|([a-f0-9]{12}|[a-f0-9]{64})/json)" "-watchdoginterval=300" "-stoponwatchdog" "-shutdowngracetime=10" ];
    user = "nobody:docker";
    log-driver = "journald";
    extraOptions = [
      "--cap-drop=ALL"
      "--network-alias=dockerproxy-homarr"
      "--network=socket-proxy-homarr"
      "--security-opt=no-new-privileges"
    ];
  };
  systemd.services."docker-dockerproxy-homarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-socket-proxy-homarr.service"
    ];
    requires = [
      "docker-network-socket-proxy-homarr.service"
    ];
    partOf = [
      "docker-compose-servarr-root.target"
    ];
    wantedBy = [
      "docker-compose-servarr-root.target"
    ];
  };
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
    user = "nobody:nogroup";
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
    image = "ghcr.io/homarr-labs/homarr:latest";
    environment = {
      "DISABLE_ANALYTICS" = "true";
      "DOCKER_HOSTNAMES" = "http://dockerproxy-homarr";
      "DOCKER_PORTS" = "2375";
      "PGID" = "65535";
      "PUID" = "65535";
      "SECRET_ENCRYPTION_KEY" = "foobar";
    };
    volumes = [
      "/containers/config/homarr/appdata:/appdata:rw"
    ];
    ports = [
      "7575:7575/tcp"
    ];
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
      "/containers/mediaserver/media:/data/media:ro"
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
      "8991:8989/tcp"
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
  virtualisation.oci-containers.containers."sonarr-tv-uhd" = {
    image = "ghcr.io/hotio/sonarr";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "Etc/UTC";
      "UMASK" = "002";
    };
    volumes = [
      "/containers/config/sonarr-tv-uhd:/config:rw"
      "/containers/mediaserver:/data:rw"
    ];
    ports = [
      "8990:8989/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=sonarr-tv-uhd"
      "--network=arr"
    ];
  };
  systemd.services."docker-sonarr-tv-uhd" = {
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
      "/containers/config/jellyfin/log:/jellyfin:ro"
      "/containers/config/jellyseerr/logs:/jellyseerr:ro"
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
  virtualisation.oci-containers.containers."swag-internal" = {
    image = "lscr.io/linuxserver/swag";
    environment = {
      "CERTPROVIDER" = "";
      "DNSPLUGIN" = "cloudflare";
      "DOCKER_MODS" = "linuxserver/mods:swag-auto-reload";
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
      "/containers/config/swag-internal:/config:rw"
    ];
    ports = [
      "4433:443/tcp"
      "800:80/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--network-alias=swag-internal"
      "--network=0wireguard"
      "--network=arr"
      "--network=authentik"
      "--network=dozzle"
      "--network=exposed"
      "--network=homarr"
      "--network=ldap"
      "--network=thelounge"
    ];
  };
  systemd.services."docker-swag-internal" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "docker-network-0wireguard.service"
      "docker-network-arr.service"
      "docker-network-dozzle.service"
      "docker-network-exposed.service"
      "docker-network-homarr.service"
      "docker-network-thelounge.service"
    ];
    requires = [
      "docker-network-0wireguard.service"
      "docker-network-arr.service"
      "docker-network-dozzle.service"
      "docker-network-exposed.service"
      "docker-network-homarr.service"
      "docker-network-thelounge.service"
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
  virtualisation.oci-containers.containers."wg-easy" = {
    image = "ghcr.io/wg-easy/wg-easy";
    environment = {
      "LANG" = "en";
      "PASSWORD_HASH" = "<Hash>";
      "PORT" = "51821";
      "WG_HOST" = "<Host IP>";
      "WG_PORT" = "51820";
    };
    volumes = [
      "/containers/config/wg-easy:/etc/wireguard:rw"
    ];
    dependsOn = [
      "dnsmasq"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--cap-add=SYS_MODULE"
      "--network=container:dnsmasq"
      "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
      "--sysctl=net.ipv4.ip_forward=1"
    ];
  };
  systemd.services."docker-wg-easy" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    partOf = [
      "docker-compose-servarr-root.target"
    ];
    wantedBy = [
      "docker-compose-servarr-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-0wireguard" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f 0wireguard";
    };
    script = ''
      docker network inspect 0wireguard || docker network create 0wireguard
    '';
    partOf = [ "docker-compose-servarr-root.target" ];
    wantedBy = [ "docker-compose-servarr-root.target" ];
  };
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
  systemd.services."docker-network-dozzle" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f dozzle";
    };
    script = ''
      docker network inspect dozzle || docker network create dozzle
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
  systemd.services."docker-network-homarr" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f homarr";
    };
    script = ''
      docker network inspect homarr || docker network create homarr
    '';
    partOf = [ "docker-compose-servarr-root.target" ];
    wantedBy = [ "docker-compose-servarr-root.target" ];
  };
  systemd.services."docker-network-socket-proxy-dozzle" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f socket-proxy-dozzle";
    };
    script = ''
      docker network inspect socket-proxy-dozzle || docker network create socket-proxy-dozzle
    '';
    partOf = [ "docker-compose-servarr-root.target" ];
    wantedBy = [ "docker-compose-servarr-root.target" ];
  };
  systemd.services."docker-network-socket-proxy-homarr" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f socket-proxy-homarr";
    };
    script = ''
      docker network inspect socket-proxy-homarr || docker network create socket-proxy-homarr
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
