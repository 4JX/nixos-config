{ config, lib, primaryUser, ... }:

let
  cfg = config.ncfg.programs.misc.act;
in
{
  options.ncfg.programs.misc.act.enable = lib.mkEnableOption "Act";

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;

    home-manager.users.${primaryUser} = { pkgs, ... }: {
      home.packages = with pkgs; [ act ];
    };
  };
}
