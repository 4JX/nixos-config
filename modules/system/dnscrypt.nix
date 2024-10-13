{ lib, config, ... }:

let
  cfg = config.ncfg.system.dnscrypt;
  configFile = cfg.configFile;
  # https://search.nixos.org/options?channel=unstable&show=networking.dhcpcd.enable
  dhcpcdEnable = config.networking.dhcpcd.enable;
  # https://search.nixos.org/options?channel=unstable&show=networking.networkmanager.enable
  networkmanagerEnable = config.networking.networkmanager.enable;
in
{
  options.ncfg.system.dnscrypt = {
    enable = lib.mkEnableOption "DNSCrypt as the system DNS manager";
    configFile = lib.mkOption {
      type = lib.types.path;
      # default = "/etc/dnscrypt-proxy/dnscrypt-proxy.toml";
      description = "Path to the dnscrypt-proxy configuration file";
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      nameservers = [ "127.0.0.1" "::1" ];
      # If using dhcpcd:
      dhcpcd.extraConfig = lib.mkIf dhcpcdEnable "nohook resolv.conf";
      # If using NetworkManager:
      networkmanager = lib.mkIf networkmanagerEnable {
        dns = "none";
      };
    };

    # https://wiki.nixos.org/wiki/Encrypted_DNS
    services.dnscrypt-proxy2 = {
      enable = true;
      # https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Configuration
      inherit configFile;
    };

    systemd.services.dnscrypt-proxy2.serviceConfig = {
      # StateDirectory = "dnscrypt-proxy";
      # ReadOnlyPaths = [ configFile ];
    };
  };
}
