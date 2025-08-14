{
  config,
  osConfig,
  pkgs,
  lib,
  inputs,
  homeFiles,
  ...
}:
let
  inherit (lib) mkOption mkEnableOption types;

  cfg = config.local.DE.gnome;
  osCfg = osConfig.local.DE.gnome;

  backgrounds = homeFiles + "/backgrounds";
  defaultBackground = backgrounds + "/the-frontier-moewanders.jpg";
in
{
  imports = [ ./extensions.nix ];

  options.local.DE.gnome = {
    enable = mkEnableOption "GNOME" // {
      default = osCfg.enable;
    };
    background = mkOption {
      type = types.path;
      default = defaultBackground;
      description = "The background image to use.";
    };
    extensions = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            enable = mkEnableOption "the extension" // {
              default = true;
            };
            package = mkOption {
              type = types.package;
              description = "The extension's package.";
            };
            dconfSettings = mkOption {
              # https://github.com/nix-community/home-manager/blob/master/modules/misc/dconf.nix#L48
              # https://github.com/nix-community/home-manager/blob/d2263ce5f4c251c0f7608330e8fdb7d1f01f0667/modules/programs/foliate.nix#L28
              type = with types; attrsOf (either lib.hm.types.gvariant (attrsOf lib.hm.types.gvariant));
              default = { };
              description = "The dconf settings to apply to the extension.";
            };
          };
        }
      );
      default = import ./list.nix {
        inherit
          config
          pkgs
          lib
          inputs
          ;
      };
      description = "GNOME extensions to install.";
    };
    dashMonitorElements = mkOption {
      type = types.str;
      description = "The dash-to-panel monitor panel-element-positions config to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      # GTK
      # GNOME portals don't work if force-setting this
      # GDK_BACKEND = "wayland,x11";
      # QT
      QT_QPA_PLATFORM = "wayland;xcb";
      # SDL
      SDL_VIDEODRIVER = "wayland,x11";

      # Electron, similar to OZONE_PLATFORM
      NIXOS_OZONE_WL = "1";
      # Firefox
      MOZ_ENABLE_WAYLAND = "1";
    };

    home.file = {
      ".local/share/backgrounds" = {
        source = backgrounds;
        # Link the files rather than the folder, allows for modifications through the settings page
        recursive = true;
      };
    };

    # Use dconf watch / to record changes
    # Use dconf2nix to get an idea of how to format the changes
    dconf.settings = {
      # Show minimize, maximize and close to the left of the title bar
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
      };

      # Set the various background bits
      "org/gnome/desktop/background" = {
        picture-uri = "file://${cfg.background}";
        picture-uri-dark = "file://${cfg.background}";
      };

      "org/gnome/desktop/screensaver" = {
        picture-uri = "file://${cfg.background}";
      };

      "org/gnome/desktop/interface" = {
        icon-theme = "Tela-circle-dark";

        # TODO: Find nicer cursor theme
        cursor-theme = "Adwaita";
        # cursor-theme = "Vimix-cursors";
        # cursor-size = 28; # Default 24
      };

      "org/gnome/desktop/interface" = {
        # Dark mode
        color-scheme = "prefer-dark";
        show-battery-percentage = true;

        # Font stuff
        font-name = "SF Pro 10";
        document-font-name = "SF Pro 11";
        monospace-font-name = "JetBrains Mono 10";
        titlebar-font = "SF Pro Display Bold 11";
      };

      "org/gnome/shell" = {
        # Apps to show in the dock
        favorite-apps = [
          "org.gnome.Nautilus.desktop"
          "firefox.desktop"
          "kitty.desktop"
          "codium.desktop"
          "github-desktop.desktop"
          "com.discordapp.Discord.desktop"
        ];
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        # Right click based on area rather than some second finger tap method
        click-method = "areas";
      };

      "org/gnome/settings-daemon/plugins/color" = with lib.hm.gvariant; {
        night-light-enabled = true;
        # Manual schedule, as opposed to Sunset->Sunrise
        night-light-schedule-automatic = false;
        night-light-schedule-from = 23.0; # 11PM
        night-light-schedule-to = 9.0; # 9AM
        night-light-temperature = mkUint32 3700;
      };

      "org/gnome/settings-daemon/plugins/power" = {
        # Don't go to sleep on AC (turning the screen off is still allowed)
        sleep-inactive-ac-type = "nothing";
      };

      "org/gnome/mutter" = {
        # Automatically create/delete workspaces (as opposed to having a fixed amount)
        dynamic-workspaces = true;
      };
    };
  };
}
