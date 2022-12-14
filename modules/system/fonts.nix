{ pkgs, lib, config, ... }:

let
  cfg = config.ncfg.system;
in
{
  options.ncfg.system.fonts = lib.mkOption {
    type = lib.types.listOf lib.types.path;
    default = [ ];
    description = lib.mdDoc "List of primary font paths.";
  };

  config.fonts.fonts = cfg.fonts;
}
