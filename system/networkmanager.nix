{ config, ... }:

let
  cfg = config.cfg;
in
{
  networking.networkmanager.enable = true;

  users.users.${cfg.user}.extraGroups = [ "networkmanager" ];
}
