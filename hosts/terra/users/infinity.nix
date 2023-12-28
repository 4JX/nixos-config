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
}
