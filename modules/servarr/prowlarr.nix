{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.prowlarr;
  servarrEnable = config.ncfg.servarr.enable;
in
{
  options = {
    ncfg.servarr.prowlarr.enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable;
      description = "Whether to enable Prowlarr.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.prowlarr = {
      enable = true;
    };
  };
}
