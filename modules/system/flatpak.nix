{ lib, config, ... }:

let
  cfg = config.local.system.flatpak;
in
{
  options.local.system.flatpak.enable = lib.mkEnableOption "Flatpak";

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;

    xdg.portal.enable = true;
  };
}
