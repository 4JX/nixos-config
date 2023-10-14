{ pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Select internationalization properties.
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
    iftop
    killall
    eza
    bat
    cmake
    gcc
    efibootmgr
    nvtop
    (inxi.override
      { withRecommends = true; }) # inxi -Fazy
    ripgrep # Faster grep
    # FIXME: https://github.com/NixOS/nixpkgs/issues/250306
    # ripgrep-all # Wrapper around ripgrep for convenience universal searching across a ton of filetypes
    fd # Better find

    # Nix stuffs
    nil # Nix language server
    nixpkgs-fmt
    nixos-option
    deadnix
    statix
    nix-tree # Scan current system / derivations for what-why-how depends
  ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
}

