{ lib, config, ... }:

let
  cfg = config.ncfg.system.flatpak;
in
{
  options.ncfg.system.flatpak.enable = lib.mkEnableOption "Flatpak";

  config = lib.mkIf
    cfg.enable
    {
      services.flatpak.enable = true;

      xdg.portal.enable = true;
    };
}
