{ pkgs, lib, ... }:

# To consider
# https://extensions.gnome.org/extension/2992/ideapad/

# let
#   versionReminder = (pkg: targetVer: lib.assertMsg ((builtins.compareVersions pkg.version targetVer) < 0) "${pkg.name} is up to date enough to remove the override");
# in
# assert versionReminder pkgs.gnomeExtensions.gtk4-desktop-icons-ng-ding "40";
# assert versionReminder pkgs.gnomeExtensions.muteunmute "11";

let
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
      name = "Orchis-Dark";
    };
  }

  {
    package = dash-to-panel;
    dconfSettings = {
      panel-element-positions = ''
        {"0":[{"element":"showAppsButton","visible":true,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"centerMonitor"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}]}
      '';
      panel-lengths = ''{"0":100}'';

      # Keep running apps for each workspace separate
      isolate-workspaces = true;
    };
  }

  {
    package = space-bar;
    dconfSettings = { };
  }

  {
    package = arcmenu;
    dconfSettings = {
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
    dconfSettings = { };
  }

  {
    package = tray-icons-reloaded;
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
    package = ideapad-controls;
    dconfSettings = { };
  }

  {
    package = gesture-improvements;
    dconfSettings = { };
  }

  {
    package = easyeffects-preset-selector;
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
    };
  }

  {
    package = gtk4-desktop-icons-ng-ding;
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
    };
  }

  {
    package = removable-drive-menu;
    dconfSettings = { };
  }

  {
    package = vitals;
    dconfSettings = {
      show-voltage = false;
      show-fan = false;
      show-battery = true;

      hot-sensors = [ "_battery_rate_" ];
    };
  }
]
