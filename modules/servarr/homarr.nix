{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.homarr;
  servarrEnable = config.ncfg.servarr.enable;
in
{
  options = {
    ncfg.servarr.homarr.enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable;
      description = "Whether to enable Homarr.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."homarr" = {
      image = "ghcr.io/ajnart/homarr:latest";
      environment = {
        "DISABLE_ANALYTICS" = "true";
      };
      volumes = [
        "/containers/config/homarr/configs:/app/containers/configs:rw"
        "/containers/config/homarr/data:/data:rw"
        "/containers/config/homarr/icons:/app/public/icons:rw"
        "/run/podman/podman.sock:/var/run/docker.sock:rw"
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
    systemd.services."podman-homarr" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "always";
      };
      after = [
        "podman-network-arr.service"
      ];
      requires = [
        "podman-network-arr.service"
      ];
      partOf = [
        "podman-compose-servarr-root.target"
      ];
      wantedBy = [
        "podman-compose-servarr-root.target"
      ];
    };
  };
}
