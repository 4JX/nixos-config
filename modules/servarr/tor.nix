{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.tor;
in
{
  options = {
    ncfg.servarr.tor.enable = lib.mkEnableOption "tor";
  };

  config = lib.mkIf cfg.enable {
    # Tor SOCKS5 proxy in port 9050, poor man's VPN
    # https://trash-guides.info/Prowlarr/prowlarr-setup-proxy/
    services.tor = {
      enable = cfg.enable;
      # Actually enable the SOCKS part
      client.enable = true;
      # settings.ControlPort = [ 9051 ];
    };

    environment.shellAliases = {
      # There's also ControlPort + "printf 'AUTHENTICATE\r\nSIGNAL NEWNYM\r\nquit\r\n' | nc 127.0.0.1 9051"
      new-tor-identity = "sudo killall -HUP tor";
    };
  };
}
