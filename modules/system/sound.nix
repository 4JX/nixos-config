{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.ncfg.system.sound;
in
{
  options.ncfg.system.sound = {
    enable = lib.mkEnableOption "sound";
  };

  imports = [ inputs.nix-gaming.nixosModules.pipewireLowLatency ];

  config = lib.mkIf cfg.enable {
    # Have pulseaudio as a backup to pipewire
    services.pulseaudio.enable = !config.services.pipewire.enable;

    # Allows pipewire to be realtime
    security.rtkit.enable = config.services.pipewire.enable;

    services.pipewire = {
      enable = lib.mkDefault true;
      pulse.enable = true;
      jack.enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };

      lowLatency = {
        # enable this module
        enable = true;
        # defaults (no need to be set unless modified)
        quantum = 64;
        # Rate is only really needed for pulseaudio compat, doesn't affect the extra rates
        rate = 48000;
      };

      extraConfig.pipewire = {
        "user.conf" = {
          # 44100 48000 88200 96000 176400 192000 352800 384000
          "context.properties" = {
            "default.clock.allowed-rates" = [
              44100
              48000
              88200
              96000
              176400
              192000
              352800
              384000
            ];
          };
        };
      };
    };
  };
}
