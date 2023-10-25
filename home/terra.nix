{ pkgs, mainUser, self, ... }:

let
  p = self.packages.${pkgs.system};
in
{
  hardware.ckb-next.enable = true;

  home-manager.users.${mainUser} = { pkgs, ... }: {
    home.packages = with pkgs; [
      kate
      keepassxc
      github-desktop
      spotify
      ark
      gh # Github CLI
      jetbrains.clion
      android-studio
      # handbrake
      vokoscreen-ng
      peek
      scrcpy
      tor-browser-bundle-bin
      arandr
      libreoffice
      obsidian
      node2nix
      cyberchef
      element-desktop
      figma-linux
      quassel
      p.portmaster
      dbeaver
      libsForQt5.okular
    ];

    home.stateVersion = "22.11";
  };

  ncfg = {
    programs = {
      networking = {
        syncthing = {
          enable = true;
          settings = {
            devices = {
              "Phone" = {
                id = "HBDDQGH-L3HLJKF-CPJTNNR-C5JEULN-JSBNQUQ-UH7FPOO-NQRCPXC-GXJDJAT";
              };
            };
            folders = {
              "Keepass DB" = {
                id = "Keepass DB";
                path = "/home/${mainUser}/Documents/Keepass DB";
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
                path = "/home/${mainUser}/Documents/Phone/lmi/Backups/Syncthing";
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

        p2p = {
          qBittorrent = {
            enable = true;
            port = 58902;
          };
        };

        sniffers = {
          wireshark.enable = true;
        };
      };

      gaming.enable = true;

      misc = {
        openrgb.enable = true;
      };
    };

    misc = {
      screenshot-ocr = {
        enable = true;
        languages = [ "eng" "spa" ];
      };
    };
  };
}

