{ pkgs, ... }:

# https://github.com/NotAShelf/nyx/blob/fac9b59c8239c573733f89e41b35f267ae19413d/homes/notashelf/themes/qt.nix
# TODO: Find a way to properly style qt apps god they're a pain

let
  # To be eventually fetched from home config with defaults
  conf.style.qt = {
    platformTheme = "qtct";
    theme = {
      package = pkgs.adwaita-qt;
      name = "Adwaita-Dark";
    };
  };

  cfg = conf.style;
in
{
  home.packages = with pkgs; [
    libsForQt5.qt5ct
    # Collision with tela icons
    # kdePackages.breeze-icons
    cfg.qt.theme.package
  ];

  qt = {
    enable = true;
    platformTheme.name = cfg.qt.platformTheme;
    style = {
      # name = cfg.qt.theme.name;
      # package = cfg.qt.theme.package;
    };
  };
}
