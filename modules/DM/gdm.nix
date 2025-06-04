{ lib, config, ... }:

let
  cfg = config.local.DM.gdm;
in
{
  options.local.DM.gdm = {
    enable = lib.mkEnableOption "the Gnome Display Manager";
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.gdm.enable = true;
  };
}
