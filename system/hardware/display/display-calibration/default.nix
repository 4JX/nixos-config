{ pkgs, config, lib, ... }:

let
  cfg = config.ncfg.hardware.display.colord-kde;
in
{
  options.ncfg.hardware.display.colord-kde.enable = lib.mkEnableOption "Enable display calibration support for the KDE desktop via colord";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ colord-kde ];

    services.colord.enable = true;
  };
}
