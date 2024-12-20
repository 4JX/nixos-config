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
    nerd-fonts.symbols-only
    twemoji-color-font

    # Stolen from 
    # https://github.com/PatrickShaw/patrickshaw/blob/799ab4a839d092869bf8f6a55cb3afb1d0cd0a49/personal/dotfiles/.config/fonts/conf.d/flake.nix
    # https://github.com/somasis/nixos/blob/3519e7df91f19106c779bd71c305ad82a473850e/users/somasis/desktop/study/writing.nix#L166-L172
    # See: https://dribbble.com/stories/2021/04/26/web-design-data-fonts
    # See: https://jichu4n.com/posts/the-most-popular-fonts-on-the-web-a-study/
    caladea # Cambria
    carlito # Calibri
    comic-relief # Comic Sans MS
    gelasio # Georgia
    liberation-sans-narrow # Arial Narrow
    liberation_ttf # Arial, Helvetica, Times New Roman, Courier New
    noto-fonts-extra # Arial, Times New Roman
    roboto
    open-sans
    font-awesome
  ];
in
{
  options.ncfg.system.fonts = {
    enableCommonFonts = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable some common fonts";
    };

    custom = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = lib.mdDoc "List of primary font paths.";
    };

    fontconfig = {
      enable = true;

      defaultFonts = {
        # sansSerif = [ "Inter" "Noto Sans" ];
        # serif = [ "Noto Serif" ];
        # monospace = [ "JetBrains Mono" "Noto Sans Mono" ];
        emoji = [ "Twitter Color Emoji" ];
      };
    };
  };

  config.fonts = {
    packages = (lib.optionals cfg.enableCommonFonts commonFonts) ++ cfg.custom;
  };
}
