{ config, lib, pkgs, self, ... }:
let
  p = self.packages.${pkgs.system};
  cfg = config.ncfg.DE.gnome;
in
{
  options.ncfg.DE.gnome = {
    enable = lib.mkEnableOption "the GNOME desktop environment";
  };

  config = lib.mkIf cfg.enable {
    # Just in case
    # Can technically manage system-wide with 
    # https://search.nixos.org/options?channel=unstable&show=programs.dconf.profiles&from=0&size=50&sort=relevance&type=packages&query=programs.dconf
    # but right now the GNOME config is per-user
    programs.dconf.enable = true;

    # https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
    services.xserver.desktopManager.gnome.enable = true;


    environment.gnome.excludePackages = (with pkgs; [
      epiphany # Web
      gnome-tour
      gnome-console
      yelp # Gnome help stuff
      gnome-music
      gnome-characters
      gnome-contacts
      gnome-shell-extensions # Superseded by gnome-extension-manager, not actually doing anything
      gnome-software # Software store, useless in NixOS
    ]);

    environment.systemPackages = with pkgs; [
      gnome-tweaks
      dconf2nix
      dconf-editor
      gnome-extension-manager
      dconf2nix
      # (gnomeExtensions.gtk4-desktop-icons-ng-ding.overrideAttrs (_: {
      #   patches = [
      #     (substituteAll {
      #       inherit gjs util-linux xdg-utils;
      #       util_linux = util-linux;
      #       xdg_utils = xdg-utils;
      #       src = ./desktopicons.patch;
      #       nautilus_gsettings_path = "${glib.getSchemaPath gnome.nautilus}";
      #     })
      #   ];
      # }))
    ];

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
