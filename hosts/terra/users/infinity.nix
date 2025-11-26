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
      # VirtualBox
      "vboxusers"
      # Android
      "adbusers"
      "kvm"
    ];
  };

  sops.age.keyFile = "/home/infinity/.config/sops/age/keys.txt";

  programs = {
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };

  # Setup syncthing
  services.syncthing =
    let
      user = "infinity";
    in
    {
      enable = true;
      inherit user;
      dataDir = "/home/${user}"; # configDir is set automatically from dataDir
      openDefaultPorts = true;
      group = "users";
      overrideFolders = true;
      overrideDevices = true;

      settings = {
        devices = {
          "POCO F2" = {
            id = "HBDDQGH-L3HLJKF-CPJTNNR-C5JEULN-JSBNQUQ-UH7FPOO-NQRCPXC-GXJDJAT";
          };
          "POCO F6" = {
            id = "APT4BNW-Z3XOPOO-FF5FHPJ-YP2KU7V-RW4CP6C-ACN7TJJ-OWY4GL6-65JRZAK";
          };
        };
        folders = {
          "Keepass DB" = {
            id = "Keepass DB";
            path = "/home/${user}/Documents/Keepass DB";
            devices = [
              "POCO F2"
              "POCO F6"
            ];
            versioning = {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "LMI Phone" = {
            id = "ayfdf-jbgsg";
            path = "/home/${user}/Documents/Phone/lmi/Backups/Syncthing";
            devices = [ "POCO F2" ];
            versioning = {
              type = "simple";
              params = {
                keep = "10";
              };
            };
            type = "receiveonly";
          };
          "LMI Whatsapp" = {
            id = "78hku-rwy3n";
            path = "/home/${user}/Documents/Phone/lmi/Backups/Syncthing_Whatsapp";
            devices = [ "POCO F2" ];
            versioning = {
              type = "simple";
              params = {
                keep = "10";
              };
            };
            type = "receiveonly";
          };
        };
      };
    };

  # local.virtualisation = {
  #   libvirtd.enable = true;
  # };

  # environment.systemPackages = with pkgs; [
  #   virt-manager
  #   qemu
  #   OVMF
  #   pciutils
  # ];

  # Filesharing but easy
  programs.localsend.enable = true;

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
}
