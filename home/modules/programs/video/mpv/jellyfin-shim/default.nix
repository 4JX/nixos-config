{ config, osConfig, lib, pkgs, ... }:

let
  cfg = config.ncfg.programs.video.mpv.jellyfin-mpv-shim;

  mpvEnable = config.ncfg.programs.video.mpv.enable;
  jellyfinEnable = osConfig.ncfg.servarr.jellyfin.enable;
in
{
  options.ncfg.programs.video.mpv.jellyfin-mpv-shim = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = mpvEnable && jellyfinEnable;
    };
  };

  config = lib.mkIf cfg.enable
    {
      home.packages = with pkgs; [
        jellyfin-mpv-shim
      ];

      # https://github.com/jellyfin/jellyfin-mpv-shim#external-mpv
      # https://github.com/jellyfin/jellyfin-mpv-shim/issues/266#issuecomment-1152883845
      xdg.configFile."jellyfin-mpv-shim/conf.json".source = (pkgs.substituteAll {
        src = ./conf.json;
        mpv = lib.getExe config.programs.mpv.finalPackage;
      });
    };
}
