{ config, primaryUser, ... }:
let
  # TODO: Change source when pull request lands
  easyeffects_v7 = (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/13c891efa5309d1555fda72132ab4806609aff17.tar.gz") { config = config.nixpkgs.config; }).easyeffects;
in
{
  home-manager.users.${primaryUser} = { pkgs, ... }: {
    home.packages = [ easyeffects_v7 ];

    xdg.configFile."easyeffects/output/Legion 5 Pro.json".source = ./L5P.json;
    xdg.configFile."easyeffects/output/DT880.json".source = ./DT880.json;
  };

  # For easyeffects to work correctly this needs to be enabled
  programs.dconf.enable = true;
}
