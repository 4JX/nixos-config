{ pkgs, ... }:
{
  # Use the grub bootloader.
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_6_17;
    blacklistedKernelModules = [ "nouveau" ];

    loader = {
      efi = {
        canTouchEfiVariables = true;
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
  };
}
