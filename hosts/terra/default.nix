{ ... }:

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

  networking.networkmanager.enable = true;

  services = {
    # Enable CUPS to print documents.
    printing.enable = true;

    postgresql = {
      enable = true;
    };
  };

  hardware.ckb-next.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="048d", ATTR{idProduct}=="c965", MODE="0666"
  '';

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.05";
}
