{ pkgs, primaryUser, ... }:

{
  imports = [ ./easyeffects ./shell ./kitty.nix ./syncthing.nix ];

  home-manager.useGlobalPkgs = true;

  home-manager.users.${primaryUser} = { pkgs, ... }: {

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
      tor-browser-bundle-bin
      arandr
      libreoffice
      obsidian
      nixos-option
    ];

    home.stateVersion = "22.11";
  };
}
