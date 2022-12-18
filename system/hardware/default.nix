{ lib, pkgs, config, ... }:

let
  offloadEnabled = config.hardware.nvidia.prime.offload.enable;
in
{

  imports = [
    <nixos-hardware/lenovo/legion/16ach6h>
    ./display
  ];

  # Add config on top of nixos-hardware
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia.powerManagement = lib.mkIf offloadEnabled {
    enable = true;
    finegrained = true;
  };

  services.xserver.drivers = lib.optionals offloadEnabled [
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
