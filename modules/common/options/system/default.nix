{ ... }:

{
  imports = [
    ./fonts
    ./security
    ./flatpak.nix
    ./gnome-keyring.nix
    ./networkmanager.nix
    ./pipewire.nix
    ./power-management.nix
    ./systemd.nix
  ];
}