{ lib, config, pkgs, ... }:

let
  servarrEnable = config.ncfg.servarr.enable;
  cfg = config.ncfg.servarr.authentik;
in
{
  imports = [
    ./postgresql.nix
    ./redis.nix
    ./server.nix
    ./worker.nix
  ];

  options = {
    ncfg.servarr.authentik.enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable;
      description = "Whether to enable Authentik.";
    };
  };

  config = lib.mkIf cfg.enable {
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
  };
}
