{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.local.DE.plasma;
in
{
  options.local.DE.plasma = {
    enable = lib.mkEnableOption "the PLASMA desktop environment";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.desktopManager.plasma5.enable = cfg.enable;

    environment.systemPackages = with pkgs; [ colord-kde ];

    services.colord.enable = true;
  };
}
