{ ... }:

{
  imports =
    [
      ./boot.nix
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./ncfg.nix
      ./DE.nix
      ./users
    ];

  # TODO: Should probably make an enhanced version of this that alerts when the offending package is upgraded...
  nixpkgs.config.permittedInsecurePackages = [
    # obsidian-1.4.16
    # "electron-25.9.0"
  ];

  networking.networkmanager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.05";
}
