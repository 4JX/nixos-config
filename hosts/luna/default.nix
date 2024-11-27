{ inputs, ... }:

{
  imports =
    [
      inputs.nixos-hardware.common-gpu-nvidia-nonprime
      ./boot.nix
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./ncfg.nix
      ./users
    ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
    };
  };

  networking.networkmanager.enable = true;

  services = {
    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    xserver = {
      enable = true;

      # Configure keymap in X11
      xkb.layout = "es";
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.05";
}
