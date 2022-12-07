{ lib, pkgs, ... }:

{

  specialisation = {
    external-display.configuration = ./multiple-displays;
    integrated-only.configuration = {
      system.nixos.tags = [ "integrated-only" ];
      hardware.nvidiaOptimus.disable = true;
    };
    gpu-passthrough.configuration = {
      system.nixos.tags = [ "gpu-passthrough" ];
      imports = [ ./virtualisation ];
    };
  };
}
