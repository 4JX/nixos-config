{ mainUser, config, lib, pkgs, ... }:

let
  cfg = config.ncfg.programs.networking.sniffers.wireshark;
in
{
  options.ncfg.programs.networking.sniffers.wireshark = {
    enable = lib.mkEnableOption "Wireshark";
  };

  config = lib.mkIf cfg.enable {
    users.users.${mainUser} = {
      extraGroups = [ "wireshark" ];
    };

    programs = {
      wireshark = {
        enable = true;
        package = pkgs.wireshark;
      };
    };

  };
}
