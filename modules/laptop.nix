{ lib, ... }:

{
  ncfg.system.power-management = {
    enable = lib.mkDefault true;

    tlp = {
      # Configure this on a per-device basis, should be enough to not need auto-cpufreq or others
      enable = lib.mkDefault false;
    };

    # No thoughts needed, well integrated power management
    power-profiles-daemon.enable = lib.mkDefault true;
  };
}
