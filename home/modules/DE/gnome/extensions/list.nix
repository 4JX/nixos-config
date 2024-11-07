{ pkgs, lib, inputs, ... }:

# To consider
# https://extensions.gnome.org/extension/2992/ideapad/

# let
#   versionReminder = (pkg: targetVer: lib.assertMsg ((builtins.compareVersions pkg.version targetVer) < 0) "${pkg.name} is up to date enough to remove the override");
# in
# assert versionReminder pkgs.gnomeExtensions.gtk4-desktop-icons-ng-ding "40";
# assert versionReminder pkgs.gnomeExtensions.muteunmute "11";

let
  inherit (lib.hm.gvariant) mkTuple mkUint32;
  # fixMetadata = pkg: sha256: (pkg.overrideAttrs (old: {
  #   # Replace the metadata back to its original one
  #   # To be used as
  #   # package = fixMetadata
  #   #   (muteunmute.override { version = "11"; sha256 = "sha256-suYwbYkoWI9OlwqlN9yeQFOGhPbd6RHSG0JnteqxKkU="; })
  #   #   "sha256-YKMLso8xrn+6CCbF0MGy9GbTb7nSNeHTVmRdkdbSgxM=";
  #   # https://github.com/NixOS/nixpkgs/blob/e10802309bf9ae351eb27002c85cfdeb1be3b262/pkgs/desktops/gnome/extensions/buildGnomeExtension.nix#L36
  #   installPhase =
  #     let
  #       oldMeta = (pkgs.fetchzip
  #         {
  #           url = old.src.url;
  #           stripRoot = false;
  #           inherit sha256;
  #         } + /metadata.json);
  #     in
  #     ''
  #       cp --remove-destination ${oldMeta} metadata.json

  #       ${old.installPhase}
  #     '';
  # }));
in
with pkgs.gnomeExtensions; [
  {
    # package = pkgs.gnome45Extensions."user-theme@gnome-shell-extensions.gcampax.github.com";
    package = user-themes;
    dconfSettings = {
      name = "MonoThemeDark";
    };
  }

  {
    # package = pkgs.gnome45Extensions."dash-to-panel@jderose9.github.com";
    package = dash-to-panel;
    dconfSettings = {
      panel-element-positions = ''
        {
          "0":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"centerMonitor"},{"element":"centerBox","visible":true,"position":"centerMonitor"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}],
          "1":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"centerMonitor"},{"element":"centerBox","visible":true,"position":"centerMonitor"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]
        }
      '';
      panel-lengths = ''{"0":100}'';

      # Keep running apps for each workspace separate
      isolate-workspaces = true;

      # Needed for blur-my-shell to properly work
      trans-use-custom-opacity = true;
      trans-panel-opacity = 0.1;
    };
  }

  {
    package = app-icons-taskbar;
    disable = true;
    dconfSettings = {
      position-in-panel = "CENTER";
      panel-location = "BOTTOM";

      main-panel-height = mkTuple [ true 52 ];
      icon-size = 40;
      indicator-location = "BOTTOM";

      window-previews-show-timeout = 0;
      window-previews-hide-timeout = 0;
    };
  }

  {
    # package = pkgs.gnome45Extensions."space-bar@luchrioh";
    package = space-bar;
    dconfSettings = { };
  }

  {
    package = arcmenu;
    dconfSettings = {
      # Set icon as squares thing
      arc-menu-icon = 71;
      custom-menu-button-icon-size = 32.0;

      # Menu visual appearance
      menu-height = 800;
      left-panel-width = 350;
      right-panel-width = 250;

      # Pinned apps
      pinned-app-list = [ "Files" "org.gnome.Nautilus" "org.gnome.Nautilus.desktop" "Firefox" "firefox" "firefox.desktop" "kitty" "kitty" "kitty.desktop" "Discord" "com.discordapp.Discord" "com.discordapp.Discord.desktop" "VSCodium" "code" "codium.desktop" "ArcMenu Settings" "/etc/profiles/per-user/infinity/share/gnome-shell/extensions/arcmenu@arcmenu.com/media/icons/menu_icons/arcmenu-logo-symbolic.svg" "gnome-extensions prefs arcmenu@arcmenu.com" ];

      # Search providers
      search-provider-open-windows = true; # Search for open windows
      search-provider-recent-files = true; # Search for recent files
      highlight-search-result-terms = true; # Highlight the search results (bold text)

      # Power buttons
      # Show suspend (sleep) and hibernate along with the other options
      power-options = [ (mkTuple [ 0 true ]) (mkTuple [ 1 true ]) (mkTuple [ 2 true ]) (mkTuple [ 3 true ]) (mkTuple [ 4 true ]) (mkTuple [ 5 false ]) (mkTuple [ 6 true ]) ];
    };
  }

  {
    # package = pkgs.gnome45Extensions."blur-my-shell@aunetx";
    package = blur-my-shell;
    dconfSettings = {
      "panel/static-blur" = false;
    };
  }

  {
    package = appindicator;
    dconfSettings = {
      icon-size = 18;
    };
  }

  {
    package = muteunmute;
    dconfSettings = { };
  }


  {
    package = lib.warn "Using patched ideapad-controls https://github.com/AzzamAlsharafi/ideapad-controls-gnome-extension/pull/16" ideapad-controls.overrideAttrs (old: {
      src = pkgs.fetchzip {
        url = "https://github.com/AzzamAlsharafi/ideapad-controls-gnome-extension/archive/b5994061d0bfddf96ede19292365f47fac3c6141.zip";
        # # Otherwise the metadata will get replaced
        # postFetch = "";
        sha256 = "sha256-PPjTTrPE1844FPHm/qmDUeNyUuaij4mbQDOpN8h/KAk=";
      };
    });
    dconfSettings = {
      # Show inside the quick settings menu
      tray-location = false;
    };
  }

  {
    package = gesture-improvements;
    dconfSettings = { };
  }

  {
    package = easyeffects-preset-selector;
    disable = true;
    dconfSettings = { };
  }

  {
    package = just-perfection;
    dconfSettings = {
      # Wrap around workspaces
      workspace-wrap-around = true;

      # When starting GNOME, start in (0-Desktop, 1-Overview)
      startup-status = 0;

      # Remove "Window is ready" popups
      window-demands-attention-focus = true;

      # Move the clock stuff to a more classic opinion
      # clock-menu-position = 1; # Right
      # clock-menu-position-offset = 11; # After quick settings and power menu from Aylur's
    };
  }

  {
    package = gtk4-desktop-icons-ng-ding;
    disable = true;
    dconfSettings = { };
  }

  {
    package = caffeine;
    dconfSettings = { };
  }

  {
    package = pano;
    disable = true;
    dconfSettings = {
      # Remove audio and notification cues on copy
      send-notification-on-copy = false;
      play-audio-on-copy = false;

      # Do not generate link previews for copied links
      link-previews = false;

      # Window title(?) based excludes
      exclusion-list = [ "Bitwarden" "1Password" "KeePassXC" "secrets" "org.gnome.World.Secrets" "Tor Browser" ];
    };
  }

  {
    # package = pkgs.gnome45Extensions."drive-menu@gnome-shell-extensions.gcampax.github.com";
    package = removable-drive-menu;
    dconfSettings = { };
  }

  {
    package = vitals;
    # Only really ever used it for power consumption and battery-usage-wattmeter does that
    disable = true;
    dconfSettings = {
      show-voltage = false;
      show-fan = false;
      show-battery = true;

      hot-sensors = [ "_battery_rate_" ];
    };
  }

  {
    package = battery-usage-wattmeter;
    dconfSettings = {
      # Update every 5 seconds
      interval = 5;
    };
  }

  {
    # package = pkgs.gnome45Extensions."quick-settings-audio-panel@rayzeq.github.io";
    package = quick-settings-audio-panel;
    dconfSettings = {
      # Always show the microphone slider
      always-show-input-slider = true;
    };
  }

  {
    package = gsconnect;
    dconfSettings = {
      panel-position = "top";
    };
  }

  {
    package = media-controls;
    dconfSettings = {
      label-width = mkUint32 200;
      show-control-icons-seek-backward = false;
      show-control-icons-seek-forward = false;

      extension-position = "Right";
      # After tray icons, before whatever else(?)
      extension-index = mkUint32 4;

      # Double click to skip song
      mouse-action-double = "NEXT_TRACK";
      mouse-action-scroll-up = "NONE";
      mouse-action-scroll-down = "NONE";
    };
  }

  {
    package = task-widget;
    dconfSettings = { };
  }

  # Allow managing systemd targets too
  # https://github.com/hardpixel/systemd-manager/pull/22
  {
    # package = systemd-manager;
    package = systemd-manager.overrideAttrs (old: {
      src = pkgs.applyPatches
        {
          src = old.src;
          patches = [
            (pkgs.fetchpatch {
              url = "https://github.com/hardpixel/systemd-manager/commit/7dcce7bc883bab0ba59fc63bb818385f60b159f9.patch";
              sha256 = "sha256-YWLfOeCL9AGskr2yBbi3FCiWBRbBsJoX6eY/ZuS7r1w=";
            })
          ];
        };
    });

    dconfSettings = { };
  }
]
