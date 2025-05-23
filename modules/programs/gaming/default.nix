{ lib, ... }:

{
  imports = [
    ./gamemode.nix
    ./steam.nix
  ];

  options.local.programs.gaming = {
    enable = lib.mkEnableOption "the programs required for gaming support";
  };
}
