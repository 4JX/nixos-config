{ config, lib, ... }:

let
  cfg = config.ncfg.hardware.display;
in
{
  imports = [ ./display-calibration ];

  options.ncfg.hardware.display.enableHighRefreshRate = lib.mkEnableOption "Enable 165hz on the integrated display";

  config = lib.mkIf cfg.enableHighRefreshRate {
    # Enable high refresh rate on the integrated display
    services.xserver.xrandrHeads = [
      {
        output = "eDP";
        primary = true;
        monitorConfig = ''
          Modeline "2560x1600_165.00" 777.340  2560 2608 2640 2720  1600 1603 1609 1732 -hsync -vsync
          Option "PreferredMode" "2560x1600_165.00"
        '';
      }
    ];
  };
}
