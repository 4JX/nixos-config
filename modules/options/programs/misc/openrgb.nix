{ config, lib, mainUser, pkgs, ... }:

let
  cfg = config.ncfg.programs.misc.openrgb;
in
{
  options.ncfg.programs.misc.openrgb.enable = lib.mkEnableOption "OpenRGB";

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];

    # Automagically extract and apply the built udev rules
    services.udev.packages = [ pkgs.openrgb ];

    home-manager.users.${mainUser} = { pkgs, ... }: {
      home.packages = with pkgs; [ openrgb ];
    };
  };
}
