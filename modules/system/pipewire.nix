{ config, lib, ... }:

let
  cfg = config.ncfg.system.pipewire;
in
{
  options.ncfg.system.pipewire = {
    enable = lib.mkEnableOption "Enable Pipewire";
    extraRates = lib.mkEnableOption "Enable more rates for different kinds of audio";
  };

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      config.pipewire = {
        # 44100 48000 88200 96000 176400 192000 352800 384000
        "context.properties" = lib.mkIf cfg.extraRates {
          "default.clock.allowed-rates" = [ 44100 48000 88200 96000 176400 192000 352800 384000 ];
        };
      };
    };
  };
}
