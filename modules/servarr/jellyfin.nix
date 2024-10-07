{ lib, config, ... }:

let
  cfg = config.ncfg.servarr.jellyfin;
  servarrEnable = config.ncfg.servarr.enable;
in
{
  options = {
    ncfg.servarr.jellyfin.enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable;
      description = "Whether to enable Jellyfin.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      group = "servarr";
      openFirewall = true;
    };

    users.groups.servarr.members = [ "jellyfin" ];
  };
}
