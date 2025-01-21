{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.thelounge;
  servarrEnable = config.ncfg.servarr.enable;
in
{
  options.ncfg.servarr.thelounge = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable;
      description = "Whether to enable thelounge.";
    };
    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to start thelounge automatically.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."thelounge" = {
      image = "ghcr.io/thelounge/thelounge:latest";
      inherit (cfg) autoStart;
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
      wantedBy = lib.mkForce (
        if cfg.autoStart then [
          "docker-compose-servarr-root.target"
        ] else [ ]
      );
    };
  };
}
