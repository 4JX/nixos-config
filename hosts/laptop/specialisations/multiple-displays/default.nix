{ lib, ... }:

{
  system.nixos.tags = [ "external-display" ];
  services.xserver.exportConfiguration = true;

  services.xserver = {
    # Genereated with arandr
    displayManager.setupCommands = lib.readFile ./layout.sh;
    videoDrivers = lib.mkForce [ "nvidia" ];
  };

  hardware.opengl.enable = true;
  hardware.nvidia = {
    powerManagement.enable = lib.mkForce false;
    modesetting.enable = true;
    prime = {
      offload.enable = lib.mkForce false;
      sync.enable = true;

      # Set by nixos-hardware, left here for troubleshooting
      # nvidiaBusId = "PCI:1:0:0";
      # amdgpuBusId = "PCI:6:0:0";
    };
  };
}
