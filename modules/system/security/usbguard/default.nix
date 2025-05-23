{ lib, config, ... }:

let
  cfg = config.local.system.security.usbguard;
in
{
  options.local.system.security.usbguard = {
    enable = lib.mkEnableOption "usbguard";
    rules = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
    };
  };

  config = lib.mkIf cfg.enable {
    # https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=services.usbguard
    services.usbguard = {
      # https://usbguard.github.io/documentation/configuration.html
      inherit (cfg) enable;
      inherit (cfg) rules;
    };
  };

}
