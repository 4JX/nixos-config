{ ... }:

{
  imports = [
    ./fonts
    ./hyprland
    ./security
    ./colord-kde.nix
    ./flatpak.nix
    ./gnome-keyring.nix
    ./networkmanager.nix
    ./pipewire.nix
    ./power-management.nix
    ./systemd.nix
  ];
}
