{ pkgs, ... }:

{
  imports = [
    ./hardware
    ./specialisations
  ];

  ncfg = {
    system = {
      flatpak.enable = true;
      fonts = with pkgs; [ jetbrains-mono nerdfonts twemoji-color-font ];
      pipewire = {
        enable = true;
        extraRates = true;
      };
      power-management.enable = true;
      gnome-keyring.enable = true;
      networkmanager.enable = true;
    };

    hardware.display = {
      colord-kde.enable = true;
      enableHighRefreshRate = true;
    };
  };
}
