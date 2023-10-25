{ lib, ... }:

{
  imports = [
    ./gamemode.nix
    ./steam.nix
  ];

  options.ncfg.programs.gaming = {
    enable = lib.mkEnableOption "the programs required for gaming support";
  };
}
