{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ powertop tlp tlpui ];
  # powerManagement.powertop.enable = true;

  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false;

  services.auto-cpufreq.enable = true;
  environment.etc."auto-cpufreq.conf".source = ./auto-cpufreq.conf;
}
