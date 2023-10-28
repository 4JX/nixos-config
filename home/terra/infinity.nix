{ pkgs, homeFiles, ... }:

{
  imports = [ ../modules ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";

  ncfg = {
    programs = {
      audio.easyeffects = {
        enable = true;
        outputPresets = {
          # https://github.com/wwmm/easyeffects/wiki/Community-Presets
          # Based on https://gist.github.com/sebastian-de/648555c1233fdc6688c0a224fc2fca7e
          "Legion 5 Pro" = homeFiles + /easyeffects/L5P.json;
          "DT880" = homeFiles + /easyeffects/DT880.json;
        };
      };

      browsers.firefox = {
        enable = true;
        arkenfox = {
          overrides = {
            # This is a default since https://github.com/arkenfox/user.js/releases/tag/115.1
            # "keyword.enabled" = true;
          };
        };
      };

      editors = {
        vscodium = {
          enable = true;
          mutableExtensionsDir = true;
          useVSCodeMarketplace = true;
        };
      };

      misc = {
        screenshot-ocr = {
          enable = true;
          languages = [ "eng" "spa" ];
        };
      };

      video = {
        mpv.enable = true;
      };
    };
  };

  home.packages = with pkgs; [
    qbittorrent
    openrgb
    # To be used along with the kernel module specified in the boot option
    # Adds legion_cli legion_gui to PATH
    lenovo-legion
  ];
}
