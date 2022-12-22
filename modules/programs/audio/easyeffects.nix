{ config, primaryUser, lib, ... }:
let
  cfg = config.ncfg.programs.audio.easyeffects;
in
{
  options.ncfg.programs.audio.easyeffects = {
    enable = lib.mkEnableOption "Enable Easyeffects";

    outputPresets = lib.mkOption {
      default = { };
      type = lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${primaryUser} = { pkgs, ... }: {
      home.packages = [ pkgs.unstable.easyeffects ];

      xdg.configFile =
        lib.mapAttrs' (name: value: { name = "easyeffects/output/${name}.json"; value = { source = value; }; }) cfg.outputPresets;
    };

    # For easyeffects to work correctly this needs to be enabled
    programs.dconf.enable = true;
  };

}
