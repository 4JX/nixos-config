{ pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/Madrid";


  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "es";
    #   useXkbConfig = true; # use xkbOptions in tty.
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    btop
    cudatoolkit # nvidia-smi
    iftop
    pciutils # lspci
    killall
    exa
    bat
    cmake
    gcc
    efibootmgr
    nvtop
    (inxi.override
      { withRecommends = true; }) # inxi -Fazy

    # Nix stuffs
    nil # Nix language server
    nixpkgs-fmt
    nixos-option
    deadnix
    statix
  ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
}

