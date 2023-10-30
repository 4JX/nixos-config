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

  programs = {
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };

  # Open up a port for qbittorrent
  networking.firewall =
    let
      port = 58902;
    in
    {
      allowedTCPPorts = [ port ];
      allowedUDPPorts = [ port ];
    };

  # Setup syncthing
  services.syncthing =
    let
      user = "infinity";
    in
    {
      enable = true;
      user = user;
      dataDir = "/home/${user}"; # configDir is set automatically from dataDir
      openDefaultPorts = true;
      group = "users";
      overrideFolders = true;
      overrideDevices = true;

      settings = {
        devices = {
          "Phone" = {
            id = "HBDDQGH-L3HLJKF-CPJTNNR-C5JEULN-JSBNQUQ-UH7FPOO-NQRCPXC-GXJDJAT";
          };
        };
        folders = {
          "Keepass DB" = {
            id = "Keepass DB";
            path = "/home/${user}/Documents/Keepass DB";
            devices = [ "Phone" ];
            versioning = {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "15768000";
              };
            };
          };
          "Phone" = {
            id = "ayfdf-jbgsg";
            path = "/home/${user}/Documents/Phone/lmi/Backups/Syncthing";
            devices = [ "Phone" ];
            versioning = {
              type = "simple";
              params = {
                keep = "3";
              };
            };
            type = "receiveonly";
          };
        };
      };
    };

  # Add OpenRGB udev rules
  # TODO: Somehow properly add the kernel module things it complains about
  services.udev.packages = [ pkgs.openrgb ];
}
