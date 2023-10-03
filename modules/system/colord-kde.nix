{ lib, config, pkgs, ... }:

let
  cfg = config.ncfg.system.colord-kde;
in
{
  options.ncfg.system.colord-kde.enable = lib.mkEnableOption "display calibration support for the KDE desktop via colord";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ colord-kde ];

    services.colord.enable = true;
  };
}
