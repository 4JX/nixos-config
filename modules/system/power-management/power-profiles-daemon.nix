{
  pkgs,
  config,
  lib,
  ...
}:

# Loosely based on https://gitlab.com/EikoTsukida/power-profiles-automation
# Can also consider a "low battery" trigger https://superuser.com/questions/1500635/udev-rule-for-hibernate-on-low-battery-not-working

let
  cfg = config.local.system.power-management.power-profiles-daemon;
in
{
  options.local.system.power-management.power-profiles-daemon = {
    enable = lib.mkEnableOption "power-profiles-daemon";
  };

  config = {
    services.power-profiles-daemon.enable = cfg.enable;

    local.system.power-management =
      let
        mkPPDCommand =
          profile:
          pkgs.writeShellApplication {
            name = "power-profiles-daemon_${profile}";
            runtimeInputs = with pkgs; [ power-profiles-daemon ];

            text = ''
              powerprofilesctl set ${profile}
            '';
          };

        powerSaver = mkPPDCommand "power-saver";
        balanced = mkPPDCommand "balanced";
      in
      lib.mkIf cfg.enable {
        onPlugged = [ balanced ];
        onUnplugged = [ powerSaver ];
      };
  };
}
