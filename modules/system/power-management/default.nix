{
  pkgs,
  config,
  lib,
  ...
}:

# TODO: https://github.com/NotAShelf/nyx/tree/c182362cd0e848a9175d836289596860cfacb08f/modules/core/types/laptop/power
# Adapt the concept of plugged in or not running scripts (plugged.nix) into configurable options via
# local.system.power-management.onPlugged/onUnplugged and mix the power profiles daemon scripts with the tlp part and co.
# Also stop/start services like syncthing and other stuff if their modules are enabled with optionalString or similar using ^
# Separate each power saving solution into its own file to make ^ easier
let
  cfg = config.local.system.power-management;
in
{
  imports = [ ./power-profiles-daemon.nix ];

  options.local.system.power-management = {
    enable = lib.mkEnableOption "power management";

    onPlugged = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.package;
      description = "Scripts to run when the computer is plugged into a power source";
    };

    onUnplugged = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.package;
      description = "Scripts to run when the computer is unplugged";
    };

    blacklistAmdPstate = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Blacklist the amd_pstate driver";
    };

    tlp = {
      enable = lib.mkEnableOption "TLP";
      settings = lib.mkOption {
        type =
          with lib.types;
          attrsOf (oneOf [
            bool
            int
            float
            str
            (listOf str)
          ]);
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

  config = lib.mkIf cfg.enable {
    services.udev.extraRules =
      # Loosely based on https://gitlab.com/EikoTsukida/power-profiles-automation
      # Can also consider a "low battery" trigger https://superuser.com/questions/1500635/udev-rule-for-hibernate-on-low-battery-not-working
      # Record changes with: udevadm monitor --property
      # Show attributes with (no -a for env instead): udevadm -ap (device path starting at /devices)
      let
        onPluggedScripts = builtins.map (
          script: ''SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${lib.getExe script}"''
        ) cfg.onPlugged;
        onUnpluggedScripts = builtins.map (
          script: ''SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${lib.getExe script}"''
        ) cfg.onUnplugged;
      in
      ''
        # On battery
        ${builtins.concatStringsSep "\n" onUnpluggedScripts}

        # Change if discharging, maybe better without specifying capacity?
        # SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-9][0-9]", RUN+="${builtins.concatStringsSep "\n" onPluggedScripts}"
         
        # Charging
        ${builtins.concatStringsSep "\n" onPluggedScripts}
      '';

    environment.systemPackages = with pkgs; [ powertop ] ++ lib.optionals cfg.tlp.enable [ tlp ];

    # powerManagement.powertop.enable = true;

    services.tlp = {
      inherit (cfg.tlp) enable settings;
    };

    # https://github.com/AdnanHodzic/auto-cpufreq/issues/464
    services.auto-cpufreq.enable = cfg.auto-cpufreq.enable;
    environment.etc."auto-cpufreq.conf" =
      lib.mkIf (cfg.auto-cpufreq.enable && cfg.auto-cpufreq.configPath != null)
        {
          source = cfg.auto-cpufreq.configPath;
        };

    boot.kernelParams = lib.optionals cfg.blacklistAmdPstate [
      "initcall_blacklist=amd_pstate_init"
      "amd_pstate.enable=0"
    ];
  };
}
