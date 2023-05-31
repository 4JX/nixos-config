{ config, pkgs, primaryUser, machineName, lib, ... }:

let
  offloadEnabled = config.hardware.nvidia.prime.offload.enable;
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./specialisations
      ./ncfg.nix
      ./xorg.nix
    ];

  # Use the grub bootloader.
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_6_3;
    blacklistedKernelModules = [ "nouveau" ];
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

  networking.hostName = machineName;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${primaryUser} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    # Enable the Plasma 5 Desktop Environment.
    # displayManager.sddm.enable = true;
    # desktopManager.plasma5.enable = true;

    # Configure keymap in X11
    layout = "es";

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;
  };

  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Add config on top of nixos-hardware
  # services.xserver.drivers = lib.optionals offloadEnabled [
  #   {
  #     driverName = "amdgpu";
  #     name = "amdgpu";
  #     modules = with pkgs; [ xorg.xf86videoamdgpu ];
  #     display = true;
  #     deviceSection = ''
  #       Option "VariableRefresh" "true"
  #       Option "TearFree" "1"
  #       Option "DRI" "3"
  #     '';
  #   }
  # ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
