{
  config,
  lib,
  pkgs,
  ...
}:
let
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

    environment.gnome.excludePackages = with pkgs;
      [
        epiphany # Web
        gnome-tour
        gnome-console
        yelp # Gnome help stuff
        gnome-music
        gnome-characters
        gnome-contacts
        gnome-shell-extensions # Superseded by gnome-extension-manager, not actually doing anything
        gnome-software # Software store, useless in NixOS
      ];

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
  };
}
