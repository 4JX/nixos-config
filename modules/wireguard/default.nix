{
  lib,
  pkgs,
  config,
  ...
}:

# https://wiki.nixos.org/wiki/WireGuard

let
  serverEnable = config.local.wireguard.server.enable;
  clientEnable = config.local.wireguard.client.enable;
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
