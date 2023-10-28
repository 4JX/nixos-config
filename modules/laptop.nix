{ ... }:

{
  ncfg.system.power-management = {
    enable = true;

    tlp = {
      # Configure this on a per-device basis, should be enough to not need auto-cpufreq or others
      enable = true;
    };

    # The repo seems to be dead/archived sadly
    power-profiles-daemon.enable = false;
  };
}
