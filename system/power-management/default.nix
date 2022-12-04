{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ powertop ];
  powerManagement.powertop.enable = true;

  services.auto-cpufreq.enable = true;
  environment.etc."auto-cpufreq.conf".source = ./auto-cpufreq.conf;
}
