{ osConfig, lib, homeFiles, ... }:
let
  cfg = osConfig.ncfg.DE.gnome;

  backgrounds = homeFiles + "/backgrounds";
  background = backgrounds + "/the-frontier-moewanders.jpg";
in
{
  imports = [ ./extensions ];

  config = lib.mkIf cfg.enable {
    home.file = {
      ".local/share/backgrounds" = {
        source = backgrounds;
        # Link the files rather than the folder, allows for modifications through the settings page
        recursive = true;
      };
    };

    # Use dconf watch / to record changes
    # Use dconf2nix to get an idea of how to format the changes
    dconf.settings =
      {
        # Show minimize, maximize and close to the left of the title bar
        "org/gnome/desktop/wm/preferences" = {
          button-layout = "appmenu:minimize,maximize,close";
        };

        # Set the various background bits
        "org/gnome/desktop/background" = {
          picture-uri = "file://${background}";
          picture-uri-dark = "file://${background}";
        };

        "org/gnome/desktop/screensaver" = {
          picture-uri = "file://${background}";
        };

        "org/gnome/desktop/interface" = {
          icon-theme = "Tela-circle-dark";

          cursor-theme = "Vimix-cursors";
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
          favorite-apps = [ "org.gnome.Nautilus.desktop" "firefox.desktop" "kitty.desktop" "codium.desktop" "github-desktop.desktop" "com.discordapp.Discord.desktop" ];
        };

        "org/gnome/desktop/peripherals/touchpad" = {
          # Right click based on area rather than some second finger tap method
          click-method = "areas";
        };

        "org/gnome/settings-daemon/plugins/color" =
          with lib.hm.gvariant; {
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
