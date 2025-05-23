{ config, lib, ... }:

let
  cfg = config.local.DM;
in
{
  options.local.DM = {
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
        user = config.local.DM.loginUser;
      };
    };
  };
}
