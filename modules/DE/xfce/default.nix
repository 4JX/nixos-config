{ lib, config, ... }:
let
  cfg = config.ncfg.DE.xfce;
in
{
  options.ncfg.DE.xfce = {
    enable = lib.mkEnableOption "the XFCE desktop environment";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.desktopManager.xfce.enable = cfg.enable;
  };
}
