{ lib, pkgs, ... }:

{
  time.timeZone = lib.mkDefault "Europe/Madrid";

  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    extraLocales = [
      "es_ES.UTF-8/UTF-8"
    ];
  };

  console =
    let
      # u28n?
      variant = "u24n";
    in
    {
      # HiDPI font
      font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-${variant}.psf.gz";
      keyMap = lib.mkDefault "es";
      # useXkbConfig = true; # use xkbOptions in tty.
    };
}
