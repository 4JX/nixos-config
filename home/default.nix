{ pkgs, config, ... }:

let
  cfg = config.cfg;
in
{
  imports = [ ./easyeffects ];

  home-manager.useGlobalPkgs = true;

  home-manager.users.${cfg.user} = { pkgs, ... }: {

    imports = [ ./vscodium ./firefox ];

    home.packages = with pkgs; [
      #firefox
      kate
      kitty
      keepassxc
      github-desktop
      spotify
      ark
      gh # Github CLI
    ];

    home.stateVersion = "22.11";
  };
}
