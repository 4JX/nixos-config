{ osConfig, lib, ... }:
let
  cfg = osConfig.ncfg.DE.gnome;
in
{
  imports = [ ./extensions ];

  config = lib.mkIf cfg.enable {
    # Use dconf watch / to record changes
    # Use dconf2nix to get an idea of how to format the changes
    dconf.settings =
      {

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
      };
  };
}
