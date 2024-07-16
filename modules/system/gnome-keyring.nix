{ config, lib, ... }:

let
  cfg = config.ncfg.system.gnome-keyring;
in
{
  options.ncfg.system.gnome-keyring.enable = lib.mkEnableOption "gnome-keyring";

  config = lib.mkIf cfg.enable {
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.sddm.enableGnomeKeyring = config.services.displayManager.sddm.enable;
    security.pam.services.gdm.enableGnomeKeyring = config.services.xserver.displayManager.gdm.enable;
  };
}
