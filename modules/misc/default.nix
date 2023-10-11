{ lib, config, ... }:

{
  imports = [
    ./screenshot-ocr.nix
  ];

  options.ncfg.allowedUnfree = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };

  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.ncfg.allowedUnfree;
  };
}
