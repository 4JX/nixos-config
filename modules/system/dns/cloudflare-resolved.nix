# https://nixos.wiki/wiki/Systemd-resolved
{ config, lib, ... }:

let
  cfg = config.local.system.dns.cloudflare-resolved;
in
{
  options.local.system.dns.cloudflare-resolved = {
    enable = lib.mkEnableOption "Cloudflare as the system DNS resolver";
  };

  config = lib.mkIf cfg.enable {
    networking.nameservers = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
    ];

    services.resolved = {
      enable = true;
      dnsovertls = "true";
      dnssec = "true";
      domains = [ "~." ];
      fallbackDns = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
      ];
    };
  };
}
