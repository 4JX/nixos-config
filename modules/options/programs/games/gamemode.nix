{ config, lib, ... }:

# Could add the scripts from https://github.com/NotAShelf/nyx/blob/c182362cd0e848a9175d836289596860cfacb08f/modules/core/common/gaming/gamemode.nix
# If I ever get to using hyprland

let
  cfg = config.ncfg.programs.games.gamemode;
in
{
  options.ncfg.programs.games.gamemode = {
    enable = lib.mkEnableOption "gamemode";
  };

  config = lib.mkIf cfg.enable {
    programs.gamemode = {
      enable = true;
      enableRenice = true;
      # https://github.com/FeralInteractive/gamemode/blob/master/example/gamemode.ini
      settings = {
        general = {
          # renice = 10;
        };
      };
    };
  };
}
