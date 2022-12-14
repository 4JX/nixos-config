{ pkgs, config, lib, ... }:

let
  cfg = config.ncfg.system.power-management;
in
{
  options.ncfg.system.power-management.enable = lib.mkEnableOption "Enable extra power saving options";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ powertop tlp tlpui ];
    # powerManagement.powertop.enable = true;

    services.tlp.enable = true;
    services.power-profiles-daemon.enable = false;

    services.auto-cpufreq.enable = true;
    environment.etc."auto-cpufreq.conf".source = ./auto-cpufreq.conf;
  };
}
