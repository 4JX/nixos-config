{ pkgs, ... }:

{
  imports =
    [
      ./boot.nix
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./specialisations
      ./ncfg.nix
      ./xorg.nix
      ./users
      ./power-management.nix
    ];

  #! TODO: Remove me
  # Should probably make an enhanced version of this that alerts when the offending package is upgraded...
  nixpkgs.config.permittedInsecurePackages = [
    # obsidian-1.4.16
    "electron-25.9.0"
  ];

  networking.networkmanager.enable = true;

  services = {
    # Enable CUPS to print documents.
    printing = {
      enable = true;
      drivers = with pkgs; [
        # cups-brother-hl3140cw
        # brlaser
        # (pkgs.callPackage ./brother.nix { })
      ];

    };

    postgresql = {
      enable = true;
    };
  };

  hardware.ckb-next.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="048d", ATTR{idProduct}=="c965", MODE="0666"
  '';

  programs.adb.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.05";
}
