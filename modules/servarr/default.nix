# Do I need this? https://github.com/rasmus-kirk/nixarr?tab=readme-ov-file

{ lib, config, ... }:

let
  cfg = config.ncfg.servarr;
in
{
  imports = [
    ./recyclarr
    ./gluetun.nix
    ./jellyfin.nix
    ./prowlarr.nix
    ./sonarr.nix
    ./tor.nix
  ];

  options.ncfg.servarr = {
    enable = lib.mkEnableOption "the servarr module";
  };

  config = lib.mkIf cfg.enable {
    # Empty for now
  };

}
