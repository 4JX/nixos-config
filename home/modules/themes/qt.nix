{ pkgs, ... }:

# https://github.com/NotAShelf/nyx/blob/fac9b59c8239c573733f89e41b35f267ae19413d/homes/notashelf/themes/qt.nix
# TODO: Find a way to properly style qt apps god they're a pain

let
  # To be eventually fetched from home config with defaults
  conf.style.qt = {
    platformTheme = "gnome";
    theme = {
      package = pkgs.adwaita-qt;
      name = "adwaita-dark";
    };
  };

  cfg = conf.style;
in
{
  home.packages = with pkgs;
    [
      libsForQt5.qt5ct
      breeze-icons
      cfg.qt.theme.package
    ];

  qt = {
    enable = true;
    platformTheme = cfg.qt.platformTheme;
    style = {
      name = cfg.qt.theme.name;
      package = cfg.qt.theme.package;
    };
  };
}
