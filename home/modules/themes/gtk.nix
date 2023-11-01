{ config, pkgs, self, ... }:

# https://github.com/NotAShelf/nyx/blob/fac9b59c8239c573733f89e41b35f267ae19413d/homes/notashelf/themes/gtk.nix#L15C1-L18C1

let
  p = self.packages.${pkgs.system};
  # To be eventually fetched from home config with defaults
  conf.style.gtk = {
    iconTheme = {
      name = "Tela-circle-dark";
      package = pkgs.tela-circle-icon-theme;
    };

    theme = rec {
      name = "MonoThemeDark";
      package = p.mono-gtk-theme;
      themePath = package + /share/themes/MonoThemeDark/gtk-4.0;
    };
  };

  cfg = conf.style;
in
{
  # https://github.com/NixOS/nixpkgs/issues/168484#issuecomment-1501080778 Fixes crash when figma-linux tries to save files
  xdg.systemDirs.data = with pkgs; [
    "${gtk3}/share/gsettings-schemas/gtk+3-${gtk3.version}"
    "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"
  ];

  xdg.configFile =
    let
      themePath = cfg.gtk.theme.themePath;
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


  home = {
    packages = with pkgs; [
      glib # gsettings
      cfg.gtk.theme.package
      cfg.gtk.iconTheme.package
    ];

    sessionVariables = {
      # Set GTK theme to the name specified by the gtk theme package
      GTK_THEME = "${cfg.gtk.theme.name}";

      # GTK applications should use filepickers specified by xdg
      # Or maybe not  # https://github.com/NixOS/nixpkgs/commit/ebde08adf37932ff59c27b5935840aa733965bdb
      # GTK_USE_PORTAL = "1";
    };
  };

  gtk = {
    enable = true;

    iconTheme = {
      name = cfg.gtk.iconTheme.name;
      package = cfg.gtk.iconTheme.package;
    };

    theme = {
      name = cfg.gtk.theme.name;
      package = cfg.gtk.theme.package;
    };

    # This is set in the global-er cursorTheme home-manager module
    # cursorTheme = {
    #   name = cfg.gtk.cursorTheme.name;
    #   package = cfg.gtk.cursorTheme.package;
    # };

    gtk2 = {
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      extraConfig = ''
        gtk-xft-antialias=1
        gtk-xft-hinting=1
        gtk-xft-hintstyle="hintslight"
        gtk-xft-rgba="rgb"
      '';
    };

    # https://docs.gtk.org/gtk3
    gtk3.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
      gtk-application-prefer-dark-theme = 1;
      # gtk-cursor-theme-size = 28;
    };

    # https://docs.gtk.org/gtk4
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      # gtk-cursor-theme-size = 28;
    };
  };
}
