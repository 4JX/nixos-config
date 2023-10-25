{ mainUser, ... }:

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
    ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${mainUser} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  services = {
    # Enable CUPS to print documents.
    printing.enable = true;

    postgresql = {
      enable = true;
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="048d", ATTR{idProduct}=="c965", MODE="0666"
  '';

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.05";
}
