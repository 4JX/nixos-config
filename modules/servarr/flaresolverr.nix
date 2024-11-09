{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.flaresolverr;
  servarrEnable = config.ncfg.servarr.enable;
in
{
  options.ncfg.servarr.flaresolverr = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable;
      description = "Whether to enable FlareSolverr.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."flaresolverr" = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      environment = {
        "CAPTCHA_SOLVER" = "none";
        "LOG_HTML" = "false";
        "LOG_LEVEL" = "info";
        "TZ" = config.time.timeZone;
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
    systemd.services."podman-flaresolverr" = {
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
