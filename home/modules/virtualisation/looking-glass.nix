{ osConfig, lib, ... }:

let
  cfg = osConfig.local.virtualisation.looking-glass;
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."looking-glass/client.ini".text = ''
      [input]
      # Right Control, see https://github.com/torvalds/linux/blob/master/include/uapi/linux/input-event-codes.h
      escapeKey=97
    '';
  };
}
