# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  cfg = config.cfg;
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
      /home/infinity/Documents/GitHub/nixos-hardware/lenovo/legion/16ach6h
      ./variables.nix
      ./system
      ./home
    ];

  # Use the grub bootloader.
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_6_0;
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
  };

  networking.hostName = "nixos"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Europe/Madrid";


  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  nixpkgs.config = { i18n.defaultLocale = config.i18n.defaultLocale; };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "es";
    #   useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;


  # Configure keymap in X11
  services.xserver.layout = "es";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${cfg.user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    powertop
    nixpkgs-fmt
    git
    btop
    cudatoolkit # nvidia-smi
    iftop
    pciutils # lspci
    nil # Nix language server
    killall
    exa
    bat

    # CLion deps
    cmake
    gcc
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

  specialisation = {
    external-display.configuration = {
      system.nixos.tags = [ "external-display" ];
      # boot.blacklistedKernelModules = [ "amdgpu" ];
      # services.xserver.videoDrivers = lib.mkForce [ "nvidia" "amdgpu" ];
      hardware.nvidia.prime.offload.enable = lib.mkForce false;
      hardware.nvidia.powerManagement.enable = lib.mkForce false;
      services.xserver.exportConfiguration = true;

      # hardware.nvidia.modesetting.enable = true;
      # hardware.nvidia.prime = {
      #   sync.enable = true;

      #   nvidiaBusId = "PCI:1:0:0";
      #   amdgpuBusId = "PCI:6:0:0";
      # };

      services.xserver.config = lib.mkForce ''
              Section "Files"

          FontPath "/nix/store/ai4qlj7mm95wvx8yxak9n4s3il8xc7pr-unifont-15.0.01/share/fonts"
          FontPath "/nix/store/xnnbcp6g30fxpppl3d3ykwy7gi3ppjpg-font-cursor-misc-1.0.3/lib/X11/fonts/misc"
          FontPath "/nix/store/75w1nkyx2cx8hihvnd0v0z0nxbhmn0ly-font-misc-misc-1.1.2/lib/X11/fonts/misc"
          FontPath "/nix/store/iqc4p0439yjqcqc2vrm9klxs6n6c5ib0-font-adobe-100dpi-1.0.3/lib/X11/fonts/100dpi"
          FontPath "/nix/store/zkmxpbpqhjsv3c08p8bi415b0yjkrkq4-font-adobe-75dpi-1.0.3/lib/X11/fonts/75dpi"
          ModulePath "/nix/store/v4v149jqpjibv0pv61lak75jzmyqlk4b-nvidia-x11-520.56.06-6.0.9-bin/lib/xorg/modules/drivers"
          ModulePath "/nix/store/v4v149jqpjibv0pv61lak75jzmyqlk4b-nvidia-x11-520.56.06-6.0.9-bin/lib/xorg/modules/extensions"
          ModulePath "/nix/store/s9ay0whi4jrnn5wcxvvhi1rbbsrpp08l-xorg-server-1.20.14/lib/xorg/modules"
          ModulePath "/nix/store/s9ay0whi4jrnn5wcxvvhi1rbbsrpp08l-xorg-server-1.20.14/lib/xorg/modules/drivers"
          ModulePath "/nix/store/s9ay0whi4jrnn5wcxvvhi1rbbsrpp08l-xorg-server-1.20.14/lib/xorg/modules/extensions"
          ModulePath "/nix/store/17a300nk6qvsyx6a55xkpvc3nhvajphf-xf86-input-evdev-2.10.6/lib/xorg/modules/input"
          ModulePath "/nix/store/sk1229hcxpl07ldljdfvnah6y02zla8s-xf86-input-libinput-1.2.0/lib/xorg/modules/input"

        EndSection

        Section "ServerFlags"
          Option "AllowMouseOpenFail" "on"
          Option "DontZap" "on"

        EndSection

        Section "Module"

        EndSection

        Section "Monitor"
          Identifier "Monitor[0]"

        EndSection

        # Additional "InputClass" sections
        Section "InputClass"
          Identifier "libinput mouse configuration"
          MatchDriver "libinput"
          MatchIsPointer "on"

          Option "AccelProfile" "adaptive"





          Option "LeftHanded" "off"
          Option "MiddleEmulation" "on"
          Option "NaturalScrolling" "off"

          Option "ScrollMethod" "twofinger"
          Option "HorizontalScrolling" "on"
          Option "SendEventsMode" "enabled"
          Option "Tapping" "on"

          Option "TappingDragLock" "on"
          Option "DisableWhileTyping" "off"


        EndSection

        Section "InputClass"
          Identifier "libinput touchpad configuration"
          MatchDriver "libinput"
          MatchIsTouchpad "on"

          Option "AccelProfile" "adaptive"





          Option "LeftHanded" "off"
          Option "MiddleEmulation" "on"
          Option "NaturalScrolling" "off"

          Option "ScrollMethod" "twofinger"
          Option "HorizontalScrolling" "on"
          Option "SendEventsMode" "enabled"
          Option "Tapping" "on"

          Option "TappingDragLock" "on"
          Option "DisableWhileTyping" "off"


        EndSection

        Section "ServerLayout"
        	Identifier "layout"
        	Screen 0 "nvidia"
        	Inactive "integrated"
        EndSection

        Section "Device"
        	Identifier "nvidia"
        	Driver "nvidia"
        	BusID "PCI:1:0:0"
        	# Option "Coolbits" "28"
        EndSection

        Section "Screen"
        	Identifier "nvidia"
        	Device "nvidia"
        	Option "AllowEmptyInitialConfiguration"
        EndSection

        Section "Device"
        	Identifier "integrated"
        	Driver "modesetting"
        	BusID "PCI:6:0:0"
        EndSection

        Section "Screen"
        	Identifier "integrated"
        	Device "integrated"
        EndSection
      '';

      # services.xserver.serverLayoutSection = ''
      #   	Screen 0 "Screen-nvidia[0]"
      #   	# Inactive "Screen-amdgpu[0]"
      # '';


      # services.xserver.serverLayoutSection = lib.mkForce ''
      #   Screen 0 "Screen-nvidia[0]"
      #   Inactive "Device-modesetting[0]"
      # '';

      # services.xserver.config = lib.mkAfter ''
      #   Section "Screen"
      #   	Identifier "Screen-nvidia[0]"
      #   	Device "Device-nvidia[0]"
      #   	Option "AllowEmptyInitialConfiguration"
      #   EndSection

      #   Section "Screen"
      #   	Identifier "Screen-modesetting[0]"
      #   	Device "Device-modesetting[0]"
      #   EndSection
      # '';

      # services.xserver.videoDrivers = lib.mkForce [ ];
      # services.xserver.drivers = [
      #   {
      #     driverName = "nvidia";
      #     name = "nvidia";
      #     modules = [ config.boot.kernelPackages.nvidia_x11 ];
      #     display = false;
      #     deviceSection = ''
      #       BusID "PCI:1:0:0"
      #       Option "Coolbits" "28"
      #     '';
      #     screenSection = ''
      #       Option "AllowEmptyInitialConfiguration"
      #     '';
      #   }
      #   {
      #     driverName = "modesetting";
      #     name = "modesetting";
      #     modules = [ ];
      #     display = false;
      #     deviceSection = ''
      #       BusID "PCI:6:0:0"
      #     '';
      #   }
      # ];
    };
  };
}

