{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.programs.video.mpv.jellyfin-mpv-shim;

  mpvEnable = config.local.programs.video.mpv.enable;
in
{
  options.local.programs.video.mpv.jellyfin-mpv-shim = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = mpvEnable;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.jellyfin-mpv-shim
    ];

    # https://github.com/jellyfin/jellyfin-mpv-shim#external-mpv
    # https://github.com/jellyfin/jellyfin-mpv-shim/issues/266#issuecomment-1152883845
    xdg.configFile."jellyfin-mpv-shim/conf.json".source = pkgs.replaceVars ./conf.json {
      # Do not use finalPackage here: it bundles uosc, which competes with
      # Jellyfin MPV Shim's mpvtk UI.
      mpv = lib.getExe config.programs.mpv.package;
    };

    # Shim uses its own MPV config directory when mpv_ext_no_ovr is false.
    # Include the normal generated MPV config and bindings, while letting Shim
    # own fullscreen state and the on-screen UI.
    xdg.configFile."jellyfin-mpv-shim/mpv.conf".text = ''
      include=${config.xdg.configFile."mpv/mpv.conf".source}
      input-conf=${config.xdg.configFile."mpv/input.conf".source}
      fullscreen=no
      osc=no
    '';
    xdg.configFile."jellyfin-mpv-shim/mpv.conf".force = true;
  };
}
