{ pkgs, config, ... }:

let
  cfg = config.cfg;
in
{
  imports = [ ./easyeffects.nix ];

  users.users.${cfg.user}.packages = with pkgs; [
    firefox
    kate
    kitty
    keepassxc
    vscodium
    github-desktop
    spotify
    ark
  ];
}
