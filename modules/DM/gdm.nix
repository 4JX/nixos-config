{ lib, config, ... }:

let
  cfg = config.ncfg.DM.gdm;
in
{
  options.ncfg.DM.gdm = {
    enable = lib.mkEnableOption "the Gnome Display Manager";
  };

  config = lib.mkIf cfg.enable {
    services.xserver. displayManager.gdm.enable = true;
  };
}
