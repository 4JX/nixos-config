{ config, lib, mainUser, ... }:

let
  cfg = config.ncfg.system.shell.direnv;
in
{
  options.ncfg.system.shell.direnv = {
    enable = lib.mkEnableOption "direnv";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${mainUser} = _: {
      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;
    };
  };
}
