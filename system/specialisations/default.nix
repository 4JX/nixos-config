{ lib, ... }:

{
  specialisation = {
    external-display.configuration = ./multiple-displays;
    integrated-only.configuration = {
      hardware.nvidiaOptimus.disable = true;
    };
  };
}
