{ config, lib, ... }:
let
  theme = {
    ui = {
      borders = "#0D1117";

      background = "#181A1F";

      workspace = "#21252B";

      information = "#1085FF";

      warning = "#E9D16C";

      error = "#D74E42";
    };

    ansi = {

      # Black
      black = "#5F6672";
      black_light = "#5F6672";

      # Red
      red = "#E06C75";
      red_light = "#E06C75";

      # Green
      green = "#98C379";
      green_light = "#98C379";

      # Yellow
      yellow = "#E5C07B";
      yellow_light = "#E5C07B";

      # Blue
      blue = "#61AFEF";
      blue_light = "#61AFEF";

      # Magenta
      magenta = "#B57EDC";
      magenta_light = "#B57EDC";

      # Cyan
      cyan = "#56B6C2";
      cyan_light = "#56B6C2";

      # White
      white = "#A9B2C3";
      white_light = "#A9B2C3";
    };
  };
in
{
  options.cfg = {
    primaryUser = lib.mkOption {
      default = "infinity";
      type = lib.types.str;
    };

    theme = lib.mkOption {
      default = theme;
      type = lib.types.attrs;
    };
  };

  config._module.args = {
    primaryUser = config.cfg.primaryUser;
  };
}
