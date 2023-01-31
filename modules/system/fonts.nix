{ lib, config, pkgs, ... }:

let
  cfg = config.ncfg.system.fonts;
  commonFonts = with pkgs; [
    # No tofu
    noto-fonts
    noto-fonts-extra
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif

    # Others
    jetbrains-mono
    nerdfonts
    twemoji-color-font
  ];
in
{
  options.ncfg.system.fonts = {
    enableCommonFonts = lib.mkEnableOption "Enable common fonts";

    custom = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = lib.mdDoc "List of primary font paths.";
    };
  };

  config.fonts = {
    fonts = (lib.optionals cfg.enableCommonFonts commonFonts) ++ cfg.custom;
  };
}
