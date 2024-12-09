{ inputs, ... }:

{
  imports =
    [
      inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
      ./boot.nix
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./ncfg.nix
      ./users
    ];

  # TODO: Tailscale/OpenVPN?
  services.openssh = {
    enable = true;
    ports = [ 52000 ];
    settings = {
      # Only via keys
      PermitRootLogin = "prohibit-password";
      # PermitRootLogin = "no";
      AllowUsers = [ "infinity@192.168.1.*" ];
      PasswordAuthentication = false;
    };
  };

  services.fail2ban = {
    enable = true;
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
