{ config, lib, primaryUser, ... }:

let
  cfg = config.ncfg.shell.direnv;
in
{
  options.ncfg.shell.direnv = {
    enable = lib.mkEnableOption "direnv";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${primaryUser} = _: {
      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;
    };
  };
}
