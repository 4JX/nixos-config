{
  config,
  pkgs,
  lib,
  ...
}:

# To consider
# https://extensions.gnome.org/extension/2992/ideapad/

# let
#   versionReminder = (pkg: targetVer: lib.assertMsg ((builtins.compareVersions pkg.version targetVer) < 0) "${pkg.name} is up to date enough to remove the override");
# in
# assert versionReminder pkgs.gnomeExtensions.gtk4-desktop-icons-ng-ding "40";
# assert versionReminder pkgs.gnomeExtensions.muteunmute "11";

let
  inherit (lib.hm.gvariant) mkTuple mkUint32;

  cfg = config.local.DE.gnome;
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
with pkgs.gnomeExtensions;
[
  {
    # package = pkgs.gnome45Extensions."user-theme@gnome-shell-extensions.gcampax.github.com";
    package = user-themes;
    dconfSettings = {
      name = "MonoThemeDark";
    };
  }

  {
    # package = pkgs.gnome45Extensions."dash-to-panel@jderose9.github.com";
    # package = dash-to-panel;
    package =
      lib.warn "Using patched dash-to-panel https://github.com/home-sweet-gnome/dash-to-panel/issues/2278"
        dash-to-panel.overrideAttrs
        (_old: {
          src = pkgs.fetchzip {
            url = "https://github.com/home-sweet-gnome/dash-to-panel/archive/ad8c3eac83a23846d5916330573fbc5b311ed715.zip";
            # The working dir needs to be built first, can't rely on the existing metadata replacer
            postFetch = "";
            sha256 = "sha256-Ion4+NZcTKqvBqzHe7DwxqOXWFyoZi78H7S75XuL95A=";
          };

          preBuild = ''
            make _build
            mv _build ..
            rm -rf *
            mv ../_build/* .
            rmdir ../_build
          '';
        });
    dconfSettings =
      let
        fakePrimary = "AAA-0000000000";
      in
      {
        # This is a hack to force the extension to always use the "GNOME Primary" one, as it
        # falls back from "The main monitor of the extension" when it isn't found.
        primary-monitor = fakePrimary;
        panel-element-positions-monitors-sync = true;
        # gdbus call --session --dest org.gnome.Mutter.DisplayConfig --object-path /org/gnome/Mutter/DisplayConfig --method org.gnome.Mutter.DisplayConfig.GetCurrentState
        panel-element-positions = cfg.dashMonitorElements;

        # Keep running apps for each workspace separate
        isolate-workspaces = true;

        # Needed for blur-my-shell to properly work
        trans-use-custom-opacity = true;
        trans-panel-opacity = 0.1;
      };
  }

  {
    package = app-icons-taskbar;
    enable = false;
    dconfSettings = {
      position-in-panel = "CENTER";
      panel-location = "BOTTOM";

      main-panel-height = mkTuple [
        true
        52
      ];
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
      pinned-app-list = [
        "Files"
        "org.gnome.Nautilus"
        "org.gnome.Nautilus.desktop"
        "Firefox"
        "firefox"
        "firefox.desktop"
        "kitty"
        "kitty"
        "kitty.desktop"
        "Discord"
        "com.discordapp.Discord"
        "com.discordapp.Discord.desktop"
        "VSCodium"
        "code"
        "codium.desktop"
        "ArcMenu Settings"
        "${pkgs.gnomeExtensions.arcmenu}/share/gnome-shell/extensions/arcmenu@arcmenu.com/icons/arcmenu-logo-symbolic.svg"
        "gnome-extensions prefs arcmenu@arcmenu.com"
      ];

      # Search providers
      search-provider-open-windows = true; # Search for open windows
      search-provider-recent-files = true; # Search for recent files
      highlight-search-result-terms = true; # Highlight the search results (bold text)

      # Power buttons
      # Show suspend (sleep) and hibernate along with the other options
      power-options = [
        (mkTuple [
          0
          true
        ])
        (mkTuple [
          1
          true
        ])
        (mkTuple [
          2
          true
        ])
        (mkTuple [
          3
          true
        ])
        (mkTuple [
          4
          true
        ])
        (mkTuple [
          5
          false
        ])
        (mkTuple [
          6
          true
        ])
      ];
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
    package = ideapad-controls;

    dconfSettings = {
      # Show inside the quick settings menu
      tray-location = false;
    };
  }

  {
    package = window-gestures;
    enable = false;
    dconfSettings = { };
  }

  {
    package = easyeffects-preset-selector;
    enable = false;
    dconfSettings = { };
  }

  {
    package = no-overview;
    dconfSettings = { };
  }

  {
    package = gtk4-desktop-icons-ng-ding;
    enable = false;
    dconfSettings = { };
  }

  {
    package = caffeine;
    dconfSettings = { };
  }

  {
    package = pano;
    enable = false;
    dconfSettings = {
      # Remove audio and notification cues on copy
      send-notification-on-copy = false;
      play-audio-on-copy = false;

      # Do not generate link previews for copied links
      link-previews = false;

      # Window title(?) based excludes
      exclusion-list = [
        "Bitwarden"
        "1Password"
        "KeePassXC"
        "secrets"
        "org.gnome.World.Secrets"
        "Tor Browser"
      ];
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
    enable = false;
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

  # Allow managing systemd targets too
  # https://github.com/hardpixel/systemd-manager/pull/22
  {
    # package = systemd-manager;
    package = systemd-manager.overrideAttrs (old: {
      src = pkgs.applyPatches {
        inherit (old) src;
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

  {
    package = bluetooth-battery-meter;
    dconfSettings = { };
  }
]
