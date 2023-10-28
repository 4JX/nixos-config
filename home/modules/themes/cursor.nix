{ pkgs, self, ... }:
let
  p = self.packages.${pkgs.system};

  conf.style.pointerCursor = {
    name = "Vimix-cursors";
    package = p.vimix-cursor-theme;
    size = 24;
  };

  cfg = conf.style;
in
{
  home = {
    pointerCursor = {
      package = cfg.pointerCursor.package;
      name = "${cfg.pointerCursor.name}";
      size = cfg.pointerCursor.size;
      gtk.enable = true;
      x11.enable = true;
    };
  };
}
