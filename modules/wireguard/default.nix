{
  lib,
  pkgs,
  config,
  ...
}:

# https://wiki.nixos.org/wiki/WireGuard

let
  serverEnable = config.ncfg.wireguard.server.enable;
  clientEnable = config.ncfg.wireguard.client.enable;
  enable = serverEnable || clientEnable;
in
{
  imports = [
    ./client.nix
    ./server.nix
  ];

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [ wireguard-tools ];
  };
}
