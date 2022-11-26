{ config, ... }:
let
  # TODO: Change source when pull request lands
  easyeffects_v7 = (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/13c891efa5309d1555fda72132ab4806609aff17.tar.gz") { config = config.nixpkgs.config; }).easyeffects;
  cfg = config.cfg;
in
{
  users.users.${cfg.user}.packages = [ easyeffects_v7 ];

  # For easyeffects to work correctly this needs to be enabled
  programs.dconf.enable = true;
}
