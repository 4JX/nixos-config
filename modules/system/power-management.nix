{ pkgs, config, lib, ... }:

let
  cfg = config.ncfg.system.power-management;
in
{
  options.ncfg.system.power-management = {
    enable = lib.mkEnableOption "Enable extra power saving options";

    blacklistAmdPstate = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Blacklist the amd_pstate driver";
    };

    power-profiles-daemon = {
      enable = lib.mkEnableOption "Enable power-profiles-daemon";
    };

    tlp = {
      enable = lib.mkEnableOption "Enable tlp";
    };

    auto-cpufreq = {
      enable = lib.mkEnableOption "Enable auto-cpufreq";

      configPath = lib.mkOption {
        type = lib.types.path;
        description = "Path of the auto-cpufreq config file";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.power-profiles-daemon.enable = cfg.power-profiles-daemon.enable;

    services.udev.extraRules =
      # Loosely based on https://gitlab.com/EikoTsukida/power-profiles-automation
      # Can also consider a "low battery" trigger https://superuser.com/questions/1500635/udev-rule-for-hibernate-on-low-battery-not-working
      let
        mkPPDCommand = profile: pkgs.writeShellApplication {
          name = "power-profiles-daemon_${profile}";
          runtimeInputs = with pkgs; [ power-profiles-daemon ];

          text = ''
            powerprofilesctl set ${profile}
          '';
        };

        powerSaver = mkPPDCommand "power-saver";
        balanced = mkPPDCommand "balanced";
      in
      lib.optionalString cfg.power-profiles-daemon.enable ''
        # On battery
        SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${lib.getExe powerSaver}"

        # Change if discharging
        # SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-9][0-9]", RUN+="${lib.getExe powerSaver}"
         
        # Charging
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${lib.getExe balanced}"
      '';

    environment.systemPackages = with pkgs; [ powertop ] ++ lib.optionals cfg.tlp.enable [ tlp ];

    # powerManagement.powertop.enable = true;

    services.tlp.enable = cfg.tlp.enable;

    # https://github.com/AdnanHodzic/auto-cpufreq/issues/464
    services.auto-cpufreq.enable = cfg.auto-cpufreq.enable;
    environment.etc."auto-cpufreq.conf" = lib.mkIf (cfg.auto-cpufreq.configPath != null) {
      source = cfg.auto-cpufreq.configPath;
    };

    boot.kernelParams = lib.optionals cfg.blacklistAmdPstate [ "initcall_blacklist=amd_pstate_init" "amd_pstate.enable=0" ];
  };
}
