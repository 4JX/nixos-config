{ config, lib, primaryUser, ... }:

let
  cfg = config.ncfg.shell.direnv;
in
{
  options.ncfg.shell.direnv = {
    enable = lib.mkEnableOption "Enable direnv";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${primaryUser} = { pkgs, ... }: {
      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;
    };

    nix.settings = {
      keep-outputs = true;
      keep-derivations = true;
    };
  };
}
