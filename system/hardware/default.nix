{ lib, pkgs, config, ... }:

{

  imports = [
    <nixos-hardware/lenovo/legion/16ach6h>
    ./display
  ];

  # Add config on top of nixos-hardware
  services.xserver.videoDrivers = [ "nvidia" ];

  services.xserver.drivers = lib.optionals config.hardware.nvidia.prime.offload.enable [
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
