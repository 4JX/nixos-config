{ config, primaryUser, lib, ... }:
let
  cfg = config.ncfg.home.programs.audio.easyeffects;
  # TODO: Change source when pull request lands
  easyeffects_v7 = (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/13c891efa5309d1555fda72132ab4806609aff17.tar.gz") { config = config.nixpkgs.config; }).easyeffects;
in
{
  options.ncfg.home.programs.audio.easyeffects = {
    enable = lib.mkEnableOption "Enable Easyeffects";

    outputPresets = lib.mkOption {
      default = { };
      type = lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${primaryUser} = { pkgs, ... }: {
      home.packages = [ easyeffects_v7 ];

      xdg.configFile =
        lib.mapAttrs' (name: value: { name = "easyeffects/output/${name}.json"; value = { source = value; }; }) cfg.outputPresets;
    };

    # For easyeffects to work correctly this needs to be enabled
    programs.dconf.enable = true;
  };

}
