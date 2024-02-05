{ pkgs, config, ... }:

let
  colors = config.colorScheme.palette;
in
{
  config = {
    programs.kitty = {
      enable = true;
      font = {
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono";
      };

      settings = {
        font_size = 13;
        disable_ligatures = "cursor";
        enable_audio_bell = false;

        # Theme
        background = "#${colors.base00}";

        # Black
        color0 = "#${colors.base00}";
        color8 = "#${colors.base08}";

        # Red
        color1 = "#${colors.base01}";
        color9 = "#${colors.base09}";

        # Green
        color2 = "#${colors.base02}";
        color10 = "#${colors.base0A}";

        # Yellow
        color3 = "#${colors.base03}";
        color11 = "#${colors.base0B}";

        # Blue
        color4 = "#${colors.base04}";
        color12 = "#${colors.base0C}";

        # Magenta
        color5 = "#${colors.base05}";
        color13 = "#${colors.base0D}";

        # Cyan
        color6 = "#${colors.base06}";
        color14 = "#${colors.base0E}";

        # White
        color7 = "#${colors.base07}";
        color15 = "#${colors.base0F}";
      };
    };
  };
}
