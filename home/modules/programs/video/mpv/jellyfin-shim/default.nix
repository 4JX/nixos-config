{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.programs.video.mpv.jellyfin-mpv-shim;

  mpvEnable = config.local.programs.video.mpv.enable;

  jellyfinMpvShimPkgs = pkgs.extend (
    lib.warn
      "python-mpv: patching to disable failing test: https://github.com/NixOS/nixpkgs/issues/535692"
      (
        final: prev: {
          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            (python-final: python-prev: {
              mpv = python-prev.mpv.overridePythonAttrs (oldAttrs: {
                disabledTests = (oldAttrs.disabledTests or [ ]) ++ [
                  "test_wait_for_property_concurrency"
                ];
              });
            })
          ];
        }
      )
  );
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
      jellyfinMpvShimPkgs.jellyfin-mpv-shim
    ];

    # https://github.com/jellyfin/jellyfin-mpv-shim#external-mpv
    # https://github.com/jellyfin/jellyfin-mpv-shim/issues/266#issuecomment-1152883845
    xdg.configFile."jellyfin-mpv-shim/conf.json".source = pkgs.replaceVars ./conf.json {
      mpv = lib.getExe config.programs.mpv.finalPackage;
    };
  };
}
