{ pkgs, config, ... }: {
  # Use the grub bootloader.
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_6_4;
    blacklistedKernelModules = [ "nouveau" ];
    # extraModulePackages = with config.boot.kernelPackages; [ lenovo-legion-module ];

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
  };
}
