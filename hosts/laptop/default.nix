{ primaryUser, ... }:

{
  imports =
    [
      ./boot.nix
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./specialisations
      ./ncfg.nix
      ./xorg.nix
    ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${primaryUser} = {
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
