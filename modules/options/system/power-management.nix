{ pkgs, config, lib, ... }:

# TODO: https://github.com/NotAShelf/nyx/tree/c182362cd0e848a9175d836289596860cfacb08f/modules/core/types/laptop/power
let
  cfg = config.ncfg.system.power-management;
in
{
  options.ncfg.system.power-management = {
    blacklistAmdPstate = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Blacklist the amd_pstate driver";
    };

    power-profiles-daemon = {
      enable = lib.mkEnableOption "power-profiles-daemon";
    };

    tlp = {
      enable = lib.mkEnableOption "TLP";
      settings = lib.mkOption {
        type = with lib.types; attrsOf (oneOf [ bool int float str (listOf str) ]);
        default = { };
      };
    };

    auto-cpufreq = {
      enable = lib.mkEnableOption "auto-cpufreq";

      configPath = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        description = "Path of the auto-cpufreq config file";
        default = null;
      };
    };
  };

  config = {
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

    services.tlp = {
      enable = cfg.tlp.enable;
      settings = cfg.tlp.settings;
    };

    # https://github.com/AdnanHodzic/auto-cpufreq/issues/464
    services.auto-cpufreq.enable = cfg.auto-cpufreq.enable;
    environment.etc."auto-cpufreq.conf" = lib.mkIf (cfg.auto-cpufreq.configPath != null) {
      source = cfg.auto-cpufreq.configPath;
    };

    boot.kernelParams = lib.optionals cfg.blacklistAmdPstate [ "initcall_blacklist=amd_pstate_init" "amd_pstate.enable=0" ];
  };
}
