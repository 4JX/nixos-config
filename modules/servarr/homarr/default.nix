{ lib, config, pkgs, ... }:

let
  cfg = config.ncfg.servarr.homarr;
  servarrCfg = config.ncfg.servarr;
  servarrEnable = servarrCfg.enable;
in
{
  imports = [
    ./homarr.nix
    ./socket-proxy.nix
  ];

  options = {
    ncfg.servarr.homarr.enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable;
      description = "Whether to enable Homarr.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Extracted from docker-compose.nix
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
  };
}
