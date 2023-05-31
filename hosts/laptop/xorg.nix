{ config, lib, ... }:

# https://github.com/NixOS/nixpkgs/blob/0491659cd060c6eace115483318f53c8419f9909/nixos/modules/hardware/video/nvidia.nix

let
  # https://github.com/NixOS/nixpkgs/blob/0491659cd060c6eace115483318f53c8419f9909/nixos/modules/hardware/video/nvidia.nix#L8-L23
  nvidia_x11 = config.hardware.nvidia.package;

  cfg = config.hardware.nvidia;
  pCfg = cfg.prime;
  syncCfg = pCfg.sync;
  offloadCfg = pCfg.offload;

  igpuDriver = "modesetting";
  igpuBusId = "PCI:6:0:0";
  nvidiaBusId = "PCI:1:0:0";
in

# Adapted from https://github.com/NixOS/nixpkgs/blob/0491659cd060c6eace115483318f53c8419f9909/nixos/modules/hardware/video/nvidia.nix#L330-L362
with lib; {
  # Disabled from loading in nixos-hardware but not put anywhere afterwards
  boot.kernelModules = [ "amdgpu" ];

  services.xserver.exportConfiguration = true;

  services.xserver.drivers = lib.mkForce
    [
      {
        name = igpuDriver;
        display = offloadCfg.enable;
        # modules = optionals (igpuDriver == "amdgpu") [ pkgs.xorg.xf86videoamdgpu ];
        deviceSection = ''
          BusID "${igpuBusId}"
          ${optionalString (syncCfg.enable && igpuDriver != "amdgpu") ''Option "AccelMethod" "none"''}
        '';
      }

      {
        name = "nvidia";
        modules = [ nvidia_x11.bin ];
        display = !offloadCfg.enable;
        deviceSection =
          ''
            BusID "${nvidiaBusId}"
            ${optionalString pCfg.allowExternalGpu "Option \"AllowExternalGpus\""}
          '';
        screenSection =
          ''
            Option "RandRRotation" "on"
          '' + optionalString syncCfg.enable ''
            Option "AllowEmptyInitialConfiguration"
          '' + optionalString cfg.forceFullCompositionPipeline ''
            Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
            Option         "AllowIndirectGLXProtocol" "off"
            Option         "TripleBuffer" "on"
          ''
        ;
      }
    ];

  services.xserver.serverLayoutSection = optionalString syncCfg.enable (lib.mkForce ''
    Inactive "Device-${igpuDriver}[0]"
  '');
}
