{ pkgs, config, ... }:

let
  cfg = config.cfg;
in
{
  imports = [ ./easyeffects ./shell ./kitty.nix ];

  home-manager.useGlobalPkgs = true;

  home-manager.users.${cfg.user} = { pkgs, config, ... }: {

    imports = [
      ./vscodium
      ./firefox
    ];

    home.packages = with pkgs; [
      kate
      keepassxc
      github-desktop
      spotify
      ark
      gh # Github CLI
      jetbrains.clion
      android-studio
      mpv
      handbrake
      vokoscreen-ng
      peek
      qbittorrent
      scrcpy
    ];

    home.stateVersion = "22.11";
  };
}
