{ pkgs, config, ... }:

let
  cfg = config.cfg;
in
{
  imports = [ ./easyeffects ];

  home-manager.useGlobalPkgs = true;

  home-manager.users.${cfg.user} = { pkgs, ... }: {

    home.packages = with pkgs; [
      firefox
      kate
      kitty
      keepassxc
      vscodium
      github-desktop
      spotify
      ark
    ];

    home.stateVersion = "22.11";
  };
}
