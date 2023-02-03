{ config, lib, primaryUser, ... }:

let
  cfg = config.ncfg.programs.editors.android-studio;
in
{
  options.ncfg.programs.editors.android-studio = {
    enable = lib.mkEnableOption "Enable Android Studio";


  };

  config = lib.mkIf cfg.enable {
    programs.adb.enable = true;

    home-manager.users.${primaryUser} = { pkgs, ... }: {
      home.packages = with pkgs; [
        android-studio
      ];

    };
  };
}
