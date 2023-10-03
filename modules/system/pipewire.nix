{ config, lib, ... }:

let
  cfg = config.ncfg.system.pipewire;
in
{
  options.ncfg.system.pipewire = {
    enable = lib.mkEnableOption "Pipewire";
    extraRates = lib.mkEnableOption "more rates for different kinds of audio";
  };

  config = lib.mkIf cfg.enable {
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    environment.etc."pipewire/pipewire.conf.d/user.conf".text = lib.mkIf cfg.extraRates (builtins.toJSON {
      # 44100 48000 88200 96000 176400 192000 352800 384000
      "context.properties" = {
        "default.clock.allowed-rates" = [ 44100 48000 88200 96000 176400 192000 352800 384000 ];
      };
    });
  };
}
