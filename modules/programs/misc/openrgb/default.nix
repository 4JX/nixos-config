{ config, pkgs, lib, primaryUser, ... }:

let
  cfg = config.ncfg.programs.misc.openrgb;
in
{
  options.ncfg.programs.misc.openrgb.enable = lib.mkEnableOption "Enable OpenRGB";

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];

    services.udev.extraRules = builtins.readFile ./60-openrgb.rules;

    home-manager.users.${primaryUser} = { pkgs, ... }: {
      home.packages = with pkgs; [ openrgb ];
    };
  };
}
