{ lib, config, ... }:
let
  cfg = config.local.DE.xfce;
in
{
  options.local.DE.xfce = {
    enable = lib.mkEnableOption "the XFCE desktop environment";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.desktopManager.xfce.enable = cfg.enable;
  };
}
