{ config, lib, mainUser, ... }:

let
  cfg = config.ncfg.system.shell.starship;
in
{
  options.ncfg.system.shell.starship = {
    enable = lib.mkEnableOption "Starship";
    enableZshIntegration = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${mainUser} = _: {

      programs.starship = {
        enable = true;
        inherit (cfg) enableZshIntegration;

        settings = {

          character = {
            success_symbol = "[»](bold green)";
            error_symbol = "[×](bold red) ";
          };

          git_status = {
            ahead = "↑";
            behind = "↓";
            diverged = "↕";
            modified = "!";
            staged = "±";
            renamed = "→";
          };
        };
      };
    };
  };
}