{ lib, pkgs, ... }:

{

  imports = [
    <nixos-hardware/lenovo/legion/16ach6h>
    ./display
  ];

  ncfg.hardware.display = {
    colord-kde.enable = true;
    enableHighRefreshRate = true;
  };

  # NixOS harware has nice defaults, need more than that
  services.xserver.videoDrivers = lib.mkForce [ ];

  services.xserver.drivers = [
    {
      driverName = "amdgpu";
      name = "amdgpu";
      modules = with pkgs; [ xorg.xf86videoamdgpu ];
      display = true;
      deviceSection = ''
        Option "VariableRefresh" "true"
        Option "TearFree" "1"
        Option "DRI" "3"
      '';
    }
  ];
}
