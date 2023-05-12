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

    auto-cpufreq = {
      configPath = lib.mkOption {
        type = lib.types.path;
        description = "Path of the auto-cpufreq config file";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ powertop tlp ];
    # powerManagement.powertop.enable = true;

    services.tlp.enable = true;
    services.power-profiles-daemon.enable = false;

    # https://github.com/AdnanHodzic/auto-cpufreq/issues/464
    services.auto-cpufreq.enable = true;
    environment.etc."auto-cpufreq.conf" = lib.mkIf (cfg.auto-cpufreq.configPath != null) {
      source = cfg.auto-cpufreq.configPath;
    };

    boot.kernelParams = lib.optionals cfg.blacklistAmdPstate [ "initcall_blacklist=amd_pstate_init" "amd_pstate.enable=0" ];
  };
}
