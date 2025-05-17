{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:

let
  cfg = config.ncfg.programs.audio.easyeffects;
in
{
  options.ncfg.programs.audio.easyeffects = {
    enable = lib.mkEnableOption "EasyEffects";

    outputPresets = lib.mkOption {
      default = { };
      type = lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        # EasyEffects needs dconf for it to work
        assertion = osConfig.programs.dconf.enable;
        message = ''
          dconf is not enabled for the system.
          Consider setting `config.programs.dconf.enable` in your nixpkgs configuration
        '';
      }
    ];

    home.packages = [ pkgs.easyeffects ];

    xdg.configFile = lib.mapAttrs' (name: value: {
      name = "easyeffects/output/${name}.json";
      value = {
        source = value;
      };
    }) cfg.outputPresets;
  };
}
