{ ... }:

{
  imports = [
    ./flatpak.nix
    ./fonts.nix
    ./gnome-keyring.nix
    ./pipewire.nix
    ./power-management
    ./networkmanager.nix
  ];
}
