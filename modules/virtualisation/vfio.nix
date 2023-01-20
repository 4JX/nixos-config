{ config, lib, ... }:

let
  cfg = config.ncfg.virtualisation.vfio;
in
{
  options.ncfg.virtualisation.vfio = {
    enable = lib.mkEnableOption "Enable the vfio kernel parameters and modules";

    blacklistNvidia = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Blacklist the nvidia and noveau drivers";
    };

    pciIds = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.string;
      description = "The list of PCI IDs the vfio driver should use";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelParams = [ "amd_iommu=on" ];
    boot.kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];

    boot.blacklistedKernelModules = lib.optionals cfg.blacklistNvidia [ "nvidia" "nouveau" ];

    boot.extraModprobeConfig = "options vfio-pci ids=${lib.concatStringsSep "," cfg.pciIds }";
  };
}
