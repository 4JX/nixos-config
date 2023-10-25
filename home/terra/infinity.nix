{ pkgs, ... }:

{
  imports = [ ../modules ];

  # https://github.com/NixOS/nixpkgs/issues/168484#issuecomment-1501080778 Fixes crash when figma-linux tries to save files
  xdg.systemDirs.data = with pkgs; [
    "${gtk3}/share/gsettings-schemas/gtk+3-${gtk3.version}"
    "${gsettings-desktop-schemas}/share/gsettings-schemas/gsettings-desktop-schemas-${gsettings-desktop-schemas.version}"
  ];

  ncfg = {
    programs = {
      audio.easyeffects = {
        enable = true;
        outputPresets = {
          # https://github.com/wwmm/easyeffects/wiki/Community-Presets
          # Based on https://gist.github.com/sebastian-de/648555c1233fdc6688c0a224fc2fca7e
          "Legion 5 Pro" = ../easyeffects/L5P.json;
          "DT880" = ../easyeffects/DT880.json;
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
