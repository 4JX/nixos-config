{ config, lib, ... }:

let
  cfg = config.ncfg.DM;
in
{
  options.ncfg.DM = {
    autoLogin = lib.mkEnableOption "";
    loginUser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };

  config = lib.mkIf cfg.autoLogin {
    services.xserver.displayManager = {
      autoLogin = {
        enable = true;
        user = config.ncfg.DM.loginUser;
      };
    };
  };
}
