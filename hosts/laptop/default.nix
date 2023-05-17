{ config, pkgs, primaryUser, hostName, lib, p, ... }:

let
  offloadEnabled = config.hardware.nvidia.prime.offload.enable;
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./specialisations
    ];

  # Use the grub bootloader.
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_6_1;
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

  networking.hostName = hostName;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  ncfg = {
    system = {
      flatpak.enable = true;
      fonts = {
        enableCommonFonts = true;
      };
      pipewire = {
        enable = true;
        extraRates = true;
      };
      power-management = {
        enable = true;
        blacklistAmdPstate = false;
        auto-cpufreq.configPath = ./auto-cpufreq.conf;
      };
      gnome-keyring.enable = true;
      networkmanager.enable = true;
      colord-kde.enable = true;
      hyprland.enable = true;
    };

    shell.zsh.shellAliases = {
      turn-off-keyboard = "sudo ${p.legion-kb-rgb}/bin/legion-kb-rgb set --effect Static -c 0,0,0,0,0,0,0,0,0,0,0,0";
    };
  };

  # Add config on top of nixos-hardware
  services.xserver.drivers = lib.optionals offloadEnabled [
    {
      driverName = "amdgpu";
      name = "amdgpu";
      modules = with pkgs; [ xorg.xf86videoamdgpu ];
      display = true;
      deviceSection = ''
        Option "VariableRefresh" "true"
        Option "TearFree" "1"
        Option "DRI" "3"
      '';
    }
  ];

  home-manager.users.${primaryUser} = _: {
    home.packages = [
      p.legion-kb-rgb
    ];
  };
}
