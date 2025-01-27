{ lib, config, pkgs, ... }:

let
  cfg = config.ncfg.servarr.authentik.worker;
  servarrEnable = config.ncfg.servarr.enable;
  authentikEnable = config.ncfg.servarr.authentik.enable;
in
{
  imports = [
    ./socket-proxy.nix
    ./worker.nix
  ];

  options = {
    ncfg.servarr.authentik.worker.enable = lib.mkOption {
      type = lib.types.bool;
      default = authentikEnable && servarrEnable;
      description = "Whether to enable the Authentik worker.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Extracted from docker-compose.nix
    systemd.services."docker-network-socket-proxy-authentik-worker" = {
      path = [ pkgs.docker ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "docker network rm -f socket-proxy-authentik-worker";
      };
      script = ''
        docker network inspect socket-proxy-authentik-worker || docker network create socket-proxy-authentik-worker
      '';
      partOf = [ "docker-compose-servarr-root.target" ];
      wantedBy = [ "docker-compose-servarr-root.target" ];
    };
  };
}
