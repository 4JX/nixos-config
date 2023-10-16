{ ... }:

{
  imports = [
    ./fonts
    ./security
    ./shell
    ./flatpak.nix
    ./gnome-keyring.nix
    ./networkmanager.nix
    ./sound.nix
    ./power-management.nix
    ./systemd.nix
  ];
}
