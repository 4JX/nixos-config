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
    systemd.services."podman-network-authentik" = {
      path = [ pkgs.podman ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "podman network rm -f authentik";
      };
      script = ''
        podman network inspect authentik || podman network create authentik
      '';
      partOf = [ "podman-compose-servarr-root.target" ];
      wantedBy = [ "podman-compose-servarr-root.target" ];
    };
    systemd.services."podman-network-ldap" = {
      path = [ pkgs.podman ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "podman network rm -f ldap";
      };
      script = ''
        podman network inspect ldap || podman network create ldap
      '';
      partOf = [ "podman-compose-servarr-root.target" ];
      wantedBy = [ "podman-compose-servarr-root.target" ];
    };
  };
}
