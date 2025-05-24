{ pkgs, config, ... }:
{
  # Use the grub bootloader.
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_6_13;
    blacklistedKernelModules = [ "nouveau" ];
    extraModulePackages = with config.boot.kernelPackages; [ lenovo-legion-module ];

    # Patch the kernel to properly load EDID
    # https://github.com/NixOS/nixpkgs/pull/279789#issuecomment-2148560802
    # https://discourse.nixos.org/t/copying-custom-edid/31593/31
    # kernelPatches = [{
    #   name = "edid-loader-fix-config";
    #   patch = null;
    #   extraConfig = ''
    #     FW_LOADER y
    #   '';
    # }];

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
      };
      timeout = 5;
    };

    supportedFilesystems = [ "ntfs" ];

    # Doesn't fix the tearing of external monitors for me
    # https://forums.developer.nvidia.com/t/nvidia-please-get-it-together-with-external-monitors-on-wayland/301684/31
    # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/650
    # Hack/Workaround: execute "sudo nvidia-smi -lgc 2000,40000" whenever using an external monitor,
    # at the expense of power consumption.(?)
    # kernelParams = [ "nvidia.NVreg_EnableGpuFirmware=0" ];
  };
}
