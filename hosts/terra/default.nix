{ pkgs, config, ... }:

{
  imports =
    [
      ./boot.nix
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # These hinder evaluation times and I've found myself rarely using them
      # ./specialisations
      ./ncfg.nix
      ./DE.nix
      ./users
      ./power-management.nix
    ];

  # TODO: Should probably make an enhanced version of this that alerts when the offending package is upgraded...
  nixpkgs.config.permittedInsecurePackages = [
    # obsidian-1.4.16
    # "electron-25.9.0"
  ];

  networking.networkmanager.enable = true;

  sops.secrets = {
    wg-terra = {
      format = "binary";
      sopsFile = config.lib.sops.mkHostPath "terra.conf";
    };

    wg-terra-lan = {
      format = "binary";
      sopsFile = config.lib.sops.mkHostPath "terra-lan.conf";
    };
  };

  networking.wg-quick.interfaces.terra = {
    autostart = false;
    configFile = config.sops.secrets.wg-terra.path;
  };
  networking.wg-quick.interfaces.terra-lan = {
    autostart = false;
    configFile = config.sops.secrets.wg-terra-lan.path;
  };

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
