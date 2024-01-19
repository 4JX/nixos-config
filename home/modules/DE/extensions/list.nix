{ pkgs, lib, inputs, ... }:

# To consider
# https://extensions.gnome.org/extension/2992/ideapad/

# let
#   versionReminder = (pkg: targetVer: lib.assertMsg ((builtins.compareVersions pkg.version targetVer) < 0) "${pkg.name} is up to date enough to remove the override");
# in
# assert versionReminder pkgs.gnomeExtensions.gtk4-desktop-icons-ng-ding "40";
# assert versionReminder pkgs.gnomeExtensions.muteunmute "11";

let
  ding = inputs.nixpkgs-ding.legacyPackages.${pkgs.system}.gnomeExtensions.gtk4-desktop-icons-ng-ding;
  inherit (lib.hm.gvariant) mkTuple;
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
    package = user-themes;
    dconfSettings = {
      name = "MonoThemeDark";
    };
  }

  {
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
    package = blur-my-shell;
    dconfSettings = {
      "panel/static-blur" = true;
    };
  }

  {
    package = (tray-icons-reloaded.overrideAttrs (old: {
      postPatch = ''
        substituteInPlace "AppManager.js" --replace "/bin/bash" "${pkgs.bash}/bin/bash"
      '';
    }));
    dconfSettings = {
      icon-size = 22;
      # Make the icons be close together while using Dash to Dock
      icon-padding-horizontal = 0;
    };
  }

  {
    package = muteunmute;
    dconfSettings = { };
  }


  {
    package = lib.warn "Using patched ideapad-controls https://github.com/AzzamAlsharafi/ideapad-controls-gnome-extension/pull/16" ideapad-controls.overrideAttrs (old: {
      src = pkgs.fetchzip {
        url = "https://github.com/AzzamAlsharafi/ideapad-controls-gnome-extension/archive/0a89792aadafd15d3e605b81b5bce6ffc7db5354.zip";
        # # Otherwise the metadata will get replaced
        # postFetch = "";
        sha256 = "sha256-BIMKzIANfGZNMdllcD5xOr8zY7PXDuU7TDLIpl2PzlQ=";
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
    # package = gtk4-desktop-icons-ng-ding;
    package = ((ding.override { version = "70"; sha256 = "sha256-EI1AOXfXHbYWsjJoHwLZDtsTawu7TJYYG2ozd6rUEdA="; }).overrideAttrs (old:
      {
        # Get rid of the metadata replacement, maybe?
        src = pkgs.fetchzip {
          url = old.src.url;
          hash = old.src.outputHash;
          stripRoot = false;
        };
      }
    ));
    disable = true;
    dconfSettings = { };
  }

  {
    package = caffeine;
    dconfSettings = { };
  }

  {
    package = pano;
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
    package = quick-settings-audio-panel;
    dconfSettings = { };
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
      show-seperators = false;
      show-seek-back = false;
      show-seek-forward = false;
      show-sources-menu = false;
      extension-position = "right";
      mouse-actions = [ "toggle_info" "toggle_menu" "raise" "none" "none" "none" "none" "none" ];
    };
  }
]
