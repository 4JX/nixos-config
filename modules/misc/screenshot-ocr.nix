{ config, primaryUser, lib, pkgs, ... }:

# https://gist.github.com/numkem/904f98bbb09280cb8b15cbdaca37f267
# https://github.com/WhiteBlackGoose/dotfiles/blob/b3e5229b6bb4e5a3a052a75a3dcb0bd2cc695ce0/nix-config/home.nix#L74-L107
# https://github.com/blargg/screen_copy/blob/03e99f6132d059b5547e7f24bcc74b21c880ee47/pkgs/screen_copy.nix
# https://reddit.com/r/NixOS/comments/13uboa6/text_from_image_to_clipboard_nix_tip/

let
  cfg = config.ncfg.misc.screenshot-ocr;
  # For wayland use: grim -g "$(slurp)" - | tesseract stdin stdout | wl-copy
  mkOcr = lang: pkgs.writeShellApplication {
    name = "screen_copy_${lang}";
    runtimeInputs = with pkgs; [ xfce.xfce4-screenshooter tesseract xclip ];

    text = ''
      xfce4-screenshooter -r --save /dev/stdout | tesseract -l ${lang} stdin stdout | xclip -in -selection clipboard
    '';
  };
in
{
  options.ncfg.misc.screenshot-ocr = {
    enable = lib.mkEnableOption "Enable the screenshot OCR utility";
    languages = lib.mkOption {
      type = lib.types.listOf lib.types.string;
      default = [ ];
      description = ''
        Which languages to enable for the OCR
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${primaryUser} = { pkgs, ... }: {
      home.packages = map (lang: (mkOcr lang)) cfg.languages;

      xdg.desktopEntries =
        builtins.listToAttrs
          (map
            (lang:
              let
                ocr = mkOcr lang;
                entry = {
                  name = "Image OCR: ${lang}";
                  exec = "${ocr}/bin/${ocr.name}";
                };
              in
              {
                name = "ocr-${lang}";
                value = entry;
              }
            )
            cfg.languages);
    };
  };
}
