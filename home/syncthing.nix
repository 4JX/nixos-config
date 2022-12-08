{ primaryUser, ... }:

{
  services.syncthing = {
    enable = true;
    user = primaryUser;
    dataDir = "/home/${primaryUser}"; # configDir is set automatically from dataDir
    openDefaultPorts = true;
    group = "users";
    overrideFolders = true;
    overrideDevices = true;

    devices = {
      "Phone" = {
        id = "HBDDQGH-L3HLJKF-CPJTNNR-C5JEULN-JSBNQUQ-UH7FPOO-NQRCPXC-GXJDJAT";
      };
    };

    folders = {
      "Keepass DB" = {
        id = "Keepass DB";
        path = "/home/${primaryUser}/Documents/Keepass DB";
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
        path = "/home/${primaryUser}/Documents/Phone/lmi/Backups/Syncthing";
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

  home-manager.users.${primaryUser} = { pkgs, ... }: {

    home.packages = with pkgs; [
      # Not working, https://github.com/NixOS/nixpkgs/issues/199596
      syncthingtray
    ];

    # services.syncthing.tray = {
    #   package = pkgs.syncthingtray;
    #   enable = true;
    #   command = "${pkgs.syncthingtray} --wait";
    # };
  };
}
