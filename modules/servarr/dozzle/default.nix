{ lib, config, pkgs, ... }:

let
  cfg = config.ncfg.servarr.dozzle;
  servarrEnable = config.ncfg.servarr.enable;
in
{
  imports = [
    ./dozzle.nix
    ./socket-proxy.nix
  ];

  options = {
    ncfg.servarr.dozzle.enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable;
      description = "Whether to enable Dozzle.";
    };
  };

  config = lib.mkIf cfg.enable {
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
  };
}
