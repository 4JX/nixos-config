{ lib, config, ... }:

let
  servarrEnable = config.ncfg.servarr.enable;
in
{
  imports = [
    ./postgresql.nix
    ./redis.nix
    ./server.nix
    ./worker.nix
  ];

  options = {
    ncfg.servarr.authentik.enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable;
      description = "Whether to enable Authentik.";
    };
  };
}
