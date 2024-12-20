{ config, osConfig, lib, pkgs, ... }:

let
  mpvEnable = config.ncfg.programs.video.mpv.enable;
  jellyfinEnable = osConfig.ncfg.servarr.jellyfin.enable;
in
lib.mkIf (mpvEnable && jellyfinEnable) {
  home.packages = with pkgs; [
    jellyfin-mpv-shim
  ];

  # https://github.com/jellyfin/jellyfin-mpv-shim#external-mpv
  # https://github.com/jellyfin/jellyfin-mpv-shim/issues/266#issuecomment-1152883845
  xdg.configFile."jellyfin-mpv-shim/conf.json".source = (pkgs.substituteAll {
    src = ./conf.json;
    mpv = lib.getExe config.programs.mpv.finalPackage;
  });
}
