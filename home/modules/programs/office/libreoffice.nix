{ config, pkgs, lib, ... }:

let
  cfg = config.ncfg.programs.office.libreoffice;
in
{
  options.ncfg.programs.office.libreoffice = {
    enable = lib.mkEnableOption "LibreOffice";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.libreoffice ] ++
      (with pkgs.hunspellDicts; [
        es_ES
        en_US
        en_GB-large
      ]);
  };
}