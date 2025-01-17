# Ports are handled in dnsmasq
{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.wg-easy;
  servarrEnable = config.ncfg.servarr.enable;

  # serverPortString = builtins.toString cfg.serverPort;
  secretsFile.sopsFile = config.ncfg.servarr.secretsFolder + "/servarr.yaml";
in
{
  options.ncfg.servarr.wg-easy = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable;
      description = "Whether to enable wg-easy";
    };
    # serverPort = lib.mkOption {
    #   type = lib.types.int;
    #   default = 54000;
    #   description = "The port used for connections inside wg-easy.";
    # };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.wg-easy-env = secretsFile;

    # networking.firewall = {
    #   allowedUDPPorts = [ cfg.serverPort ];
    # };

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."wg-easy" = {
      image = "ghcr.io/wg-easy/wg-easy";
      environmentFiles = [
        config.sops.secrets.wg-easy-env.path
      ];
      volumes = [
        "/containers/config/wg-easy:/etc/wireguard:rw"
      ];
      # ports = [
      #   "${serverPortString}:51820/udp"
      #   "54001:51821/tcp"
      # ];
      dependsOn = [
        "dnsmasq"
      ];
      log-driver = "journald";
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--cap-add=SYS_MODULE"
        "--network=container:dnsmasq"
        "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
        "--sysctl=net.ipv4.ip_forward=1"
      ];
    };
    systemd.services."docker-wg-easy" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "always";
        RestartMaxDelaySec = lib.mkOverride 90 "1m";
        RestartSec = lib.mkOverride 90 "100ms";
        RestartSteps = lib.mkOverride 90 9;
      };
      partOf = [
        "docker-compose-servarr-root.target"
      ];
      wantedBy = [
        "docker-compose-servarr-root.target"
      ];
    };
  };
}
