{ pkgs, ... }: {
  # Use the grub bootloader.
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_6_10;
    blacklistedKernelModules = [ "nouveau" ];
    # extraModulePackages = with config.boot.kernelPackages; [ lenovo-legion-module ];

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
  };
}
