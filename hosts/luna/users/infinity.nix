{ pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with passwd.
  users.users.infinity = {
    isNormalUser = true;
    extraGroups = [
      # Enable sudo for the user.
      "wheel"
      "networkmanager"
      "wireshark"
      # Needed for X11 gestures in tandem with the gesture improvements extension
      "input"
    ];
  };

  sops.age.keyFile = "/home/infinity/.config/sops/age/keys.txt";

  programs = {
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };

  # Allow localsend to receive files
  # https://github.com/localsend/localsend?tab=readme-ov-file#setup
  networking.firewall = {
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };
}
