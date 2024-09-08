{ lib, config, ... }:

let
  cfg = config.ncfg.servarr;
in
{
  imports = [ ./recyclarr ];

  options.ncfg.servarr = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    # https://github.com/rasmus-kirk/nixarr?tab=readme-ov-file

    # Tor SOCKS5 proxy in port 9050, poor man's VPN
    # https://trash-guides.info/Prowlarr/prowlarr-setup-proxy/
    services.tor = {
      enable = true;
      # Actually enable the SOCKS part
      client.enable = true;
      # settings.ControlPort = [ 9051 ];
    };

    # Wrong approach
    # services.privoxy = {
    #   enable = true;
    #   # curl -s https://api.black.riseup.net/3/config/eip-service.json | jq -r '.gateways[] | .ip_address as $ip | .capabilities.transport[] | select(.type == "openvpn") | "forward /" + $ip + ":" + (if .ports | index("80") then "80" else .ports[0] end) + " ." '
    #   settings = {
    #     forward = "/204.13.164.252:80 .";
    #   };
    # };

    environment.shellAliases = {
      # There's also ControlPort + "printf 'AUTHENTICATE\r\nSIGNAL NEWNYM\r\nquit\r\n' | nc 127.0.0.1 9051"
      new-tor-identity = "sudo killall -HUP tor";
    };

    # ===== Prowlarr =====

    services.prowlarr = {
      enable = true;
    };

    # ===== Sonarr =====

    # Settings:
    # https://trash-guides.info/Sonarr/Sonarr-Quality-Settings-File-Size/ -> http://localhost:8989/settings/quality (Fallback to min 5MiB/min)
    # https://trash-guides.info/Sonarr/Sonarr-recommended-naming-scheme/ -> http://localhost:8989/settings/mediamanagement (Jellyfin season folders)
    # https://trash-guides.info/Sonarr/sonarr-setup-quality-profiles-anime/ + https://trash-guides.info/Sonarr/sonarr-setup-quality-profiles/#proper-and-repacks
    # https://trash-guides.info/Hardlinks/How-to-setup-for/ and https://trash-guides.info/Hardlinks/Examples/
    # To consider for movies: https://trash-guides.info/Misc/x265-4k/#golden-rule

    services.sonarr = {
      enable = true;
      group = "servarr";
    };

    # ===== Jellyfin =====

    services.jellyfin = {
      enable = true;
      group = "servarr";
      openFirewall = true;
    };

    users.groups.servarr.members = [ "sonarr" "jellyfin" ];
  };

}
