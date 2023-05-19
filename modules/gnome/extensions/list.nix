{ pkgs, lib, ... }:

# To consider
# https://extensions.gnome.org/extension/2992/ideapad/
let
  inherit (lib.hm.gvariant) mkTuple;
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
      panel-lenghths = ''{"0":"MIDDLE"}'';

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
      # Menu visual appereance
      menu-height = 800;
      right-panel-widt = 350;
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
] ++ (with pkgs.unstable.gnomeExtensions; [
  {
    package = gesture-improvements;
    dconfSettings = { };
  }
])
