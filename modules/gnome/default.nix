{ config, primaryUser, lib, pkgs, p, ... }:
let
  cfg = config.ncfg.gnome;
  # # https://github.com/NixOS/nixpkgs/blob/nixos-22.11/pkgs/data/themes/orchis-theme/default.nix#L9
  # orchis = pkgs.orchis-theme.override {
  #   tweaks = [ ];
  # };
in
{
  imports = [ ./extensions ];

  options.ncfg.gnome = {
    enable = lib.mkEnableOption "Enable the Gnome desktop environment";
  };

  config = lib.mkIf cfg.enable {

    # Just in case
    programs.dconf.enable = true;

    # https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
    services.xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    environment.gnome.excludePackages = (with pkgs; [
      epiphany # Web
      gnome-tour
      gnome-console
    ]) ++ (with pkgs.gnome; [
      gnome-music
      gnome-characters
      yelp # Gnome help stuff
      gnome-contacts
      gnome-shell-extensions # Superseded by gnome-extension-manager, not actually doing anything
      gnome-software # Software store, useless in NixOS
    ]);

    environment.systemPackages = with pkgs; [
      gnome.gnome-tweaks
      dconf2nix
      gnome.dconf-editor
    ];

    home-manager.users.${primaryUser} = { pkgs, lib, ... }: {
      xdg.configFile =
        let
          themePath = p.mono-gtk-theme + /share/themes/MonoThemeDark/gtk-4.0;
        in
        {
          "gtk-4.0/gtk.css" = {
            source = "${themePath}/gtk.css";
          };
          "gtk-4.0/gtk-dark.css" = {
            source = "${themePath}/gtk-dark.css";
          };
          "gtk-4.0/assets" = {
            source = "${themePath}/assets";
          };
        };

      gtk = {
        enable = true;

        iconTheme = {
          name = "Tela-circle-dark";
          package = pkgs.tela-circle-icon-theme;
        };

        theme = {
          name = "MonoThemeDark";
          package = p.mono-gtk-theme;
        };

        cursorTheme = {
          name = "Vimix-cursors";
          package = p.vimix-cursor-theme;
        };

        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
          gtk-cursor-theme-size = 28;
        };

        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
          gtk-cursor-theme-size = 28;
        };
      };

      qt = {
        enable = true;
        platformTheme = "gnome";
        style = {
          package = pkgs.adwaita-qt;
          name = "adwaita-dark";
        };
      };

      home.packages = with pkgs; [
        gnome-extension-manager
      ];

      # Use dconf watch / to record changes
      # Use dconf2nix to get an idea of how to format the changes
      dconf.settings =
        {

          "org/gnome/desktop/interface" = {
            icon-theme = "Tela-circle-dark";

            cursor-theme = "Vimix-cursors";
            cursor-size = 28; # Default 24
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

    # Stuff needed for X11 gestures in tandem with the gesture improvements extension
    users.users.${primaryUser} = {
      extraGroups = [ "input" ];
    };

    # https://github.com/harshadgavali/gnome-x11-gesture-daemon/blob/main/gesture_improvements_gesture_daemon.service
    systemd.user.services."gesture_improvements_gesture_daemon" = {
      # [Unit]
      requires = [ "dbus.service" ];
      description = "gesture improvements Gesture Daemon";
      startLimitIntervalSec = 0;
      serviceConfig = {
        Type = "simple";
        ExecStart = "${p.gnome-x11-gesture-daemon}/bin/gesture_improvements_gesture_daemon";
        Restart = "always";
        RestartSec = "1s";
      };
    };
  };
}
