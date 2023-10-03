{ primaryUser, lib, config, ... }:

let
  cfg = config.ncfg.system.networkmanager;
in
{
  options.ncfg.system.networkmanager.enable = lib.mkEnableOption "networkmanager";

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;

    users.users.${primaryUser}.extraGroups = [ "networkmanager" ];
  };
}
