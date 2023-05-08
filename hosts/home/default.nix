{ pkgs, primaryUser, ... }:

{
  hardware.ckb-next.enable = true;

  home-manager.users.${primaryUser} = { pkgs, ... }: {

    # https://github.com/NixOS/nixpkgs/issues/168484#issuecomment-1501080778 Fixes crash when figma-linux tries to save files
    xdg.systemDirs.data = with pkgs; [
      "${gtk3}/share/gsettings-schemas/gtk+3-${gtk3.version}"
      "${gsettings-desktop-schemas}/share/gsettings-schemas/gsettings-desktop-schemas-${gsettings-desktop-schemas.version}"
    ];

    home.packages = with pkgs; [
      kate
      keepassxc
      github-desktop
      spotify
      ark
      gh # Github CLI
      jetbrains.clion
      android-studio
      mpv
      handbrake
      vokoscreen-ng
      peek
      qbittorrent
      scrcpy
      unstable.tor-browser-bundle-bin
      arandr
      libreoffice
      obsidian
      node2nix
      cyberchef
      element-desktop
      figma-linux
      quassel
    ];

    home.stateVersion = "22.11";
  };

  ncfg = {
    programs = {
      audio.easyeffects = {
        enable = true;
        outputPresets = {
          "Legion 5 Pro" = ./easyeffects/L5P.json;
          "DT880" = ./easyeffects/DT880.json;
        };
      };

      editors = {
        vscodium = {
          enable = true;
          mutableExtensionsDir = true;
          useVSCodeMarketplace = true;
        };

        android-studio.enable = true;
      };

      browsers.firefox = {
        enable = true;
        arkenfox = {
          # firefoxVersion = "108.0";
          sha256 = "sha256-EutseXvFnDkYq95GWiGrTFqI4fqybvsPQlVV0Wy5tFU=";
          overrides = {
            "keyword.enabled" = true;
          };
        };
      };

      networking.syncthing = {
        enable = true;
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

      games.steam = {
        enable = true;
        extraCompatPackages = with pkgs; [
          proton-ge-custom
          proton-ge-custom-621
        ];
      };

      misc = {
        openrgb.enable = true;
        act.enable = false;
      };
    };

    shell = {
      zsh = {
        enable = true;
        shellAliases = with pkgs; {
          update-config = "sudo nixos-rebuild switch";
          scrcpy = "${scrcpy}/bin/scrcpy --bit-rate 32M --encoder 'OMX.qcom.video.encoder.avc' --window-title 'Phone' --stay-awake --turn-screen-off";
          discordrpc = "ln -sf {app/com.discordapp.Discord,$XDG_RUNTIME_DIR}/discord-ipc-0";
          enable-conservation-mode = "echo 1 | sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode";
          disable-conservation-mode = "echo 0 | sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode";
          exa = "${exa}/bin/exa --icons";
        };
      };
      starship = {
        enable = true;
        enableZshIntegration = true;
      };
      kitty.enable = true;
      direnv.enable = true;
    };
  };
}

