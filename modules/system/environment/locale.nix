{ lib, pkgs, ... }:


{
  time.timeZone = lib.mkDefault "Europe/Madrid";

  i18n =
    let
      enUS = "en_US.UTF-8";
      # esES = "es_ES.UTF-8";
    in
    {
      defaultLocale = lib.mkDefault enUS;
      supportedLocales = [ "en_US.UTF-8/UTF-8" "es_ES.UTF-8/UTF-8" ];
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
