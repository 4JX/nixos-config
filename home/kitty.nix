{ pkgs, config, ... }:

let
  cfg = config.cfg;
  theme = cfg.theme;
in
{
  home-manager.users.${cfg.user} = { pkgs, config, ... }: {

    programs.kitty = {
      enable = true;
      font = {
        package = pkgs.nerdfonts;
        name = "JetbrainsMono Nerd Font";
      };
      # extraConfig = builtins.readFile ./kitty.conf;
      settings = {
        font_family = "JetBrainsMono Nerd Font Mono";
        font_size = 13;
        disable_ligatures = "cursor";
        enable_audio_bell = false;

        # Theme
        background = theme.ui.background;

        # Black
        color0 = theme.ansi.black;
        color8 = theme.ansi.black_light;

        # Red
        color1 = theme.ansi.red;
        color9 = theme.ansi.red_light;

        # Green
        color2 = theme.ansi.green;
        color10 = theme.ansi.green_light;

        # Yellow
        color3 = theme.ansi.yellow;
        color11 = theme.ansi.yellow_light;

        # Blue
        color4 = theme.ansi.blue;
        color12 = theme.ansi.blue_light;

        # Magenta
        color5 = theme.ansi.magenta;
        color13 = theme.ansi.magenta_light;

        # Cyan
        color6 = theme.ansi.cyan;
        color14 = theme.ansi.cyan_light;

        # White
        color7 = theme.ansi.white;
        color15 = theme.ansi.white_light;
      };
    };
  };
}
