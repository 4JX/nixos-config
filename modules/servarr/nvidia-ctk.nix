# https://github.com/NVIDIA/nvidia-container-toolkit
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/overview.html 
# https://jellyfin.org/docs/general/administration/hardware-acceleration/nvidia/#configure-with-linux-virtualization

# https://github.com/aksiksi/compose2nix/issues/1#issuecomment-1962458574

{ config, lib, ... }:

let
  cfg = config.ncfg.servarr.nvidia-container-toolkit;
  hasNvidia = builtins.elem "nvidia" config.services.xserver.videoDrivers;
  servarrEnable = config.ncfg.servarr.enable;
in
{
  options.ncfg.servarr.nvidia-container-toolkit = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = servarrEnable && hasNvidia;
      description = "Whether to enable nvidia-container-toolkit";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.nvidia-container-toolkit.enable = cfg.enable;
  };
}
