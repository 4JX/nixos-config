{ ... }:

{
  # https://linrunner.de/tlp/settings/operation.html
  # https://linrunner.de/tlp/support/optimizing.html
  # https://linrunner.de/tlp/faq/powercon.html
  # Made for version 1.6
  local.system.power-management = {
    power-profiles-daemon.enable = true;

    tlp.enable = false;

    tlp.settings = {
      # https://linrunner.de/tlp/settings/audio.html#sound-power-save-on-ac-bat
      SOUND_POWER_SAVE_ON_AC = 0; # Default 1
      SOUND_POWER_SAVE_ON_BAT = 10;

      # https://linrunner.de/tlp/settings/audio.html#sound-power-save-on-ac-bat
      # This is maybe available if using the legion driver?
      # PLATFORM_PROFILE_ON_AC = "performance";
      # PLATFORM_PROFILE_ON_BAT = "low-power"; # balanced?

      # https://linrunner.de/tlp/settings/processor.html#cpu-driver-opmode-on-ac-bat
      # Worth experimenting with guided since it allows control via min/max frequency
      CPU_DRIVER_OPMODE_ON_AC = "active";
      CPU_DRIVER_OPMODE_ON_BAT = "active";

      # https://linrunner.de/tlp/settings/processor.html#cpu-driver-opmode-on-ac-bat
      # Performance basically locks the hint to "full throttle" as well,
      # guided can probably do better by allowing more governor choices (schedutil ?)
      CPU_SCALING_GOVERNOR_ON_AC = "performance"; # Default powersave
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # https://linrunner.de/tlp/settings/processor.html#cpu-scaling-min-max-freq-on-ac-bat
      # This is ignored in EPP active mode, respected in guided

      # https://linrunner.de/tlp/settings/processor.html#cpu-energy-perf-policy-on-ac-bat
      # EPP driver active mode only
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power"; # Default balance_power

      # https://linrunner.de/tlp/settings/processor.html#cpu-boost-on-ac-bat
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # https://linrunner.de/tlp/settings/radio.html#devices-to-disable-on-startup
      #* Bluetooth is rarely if ever used
      # Wireless Wide Area Network technologies are not even a thing on this laptop, but left in regardless
      DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth wwan";

      # https://linrunner.de/tlp/settings/usb.html
      #* TLP configures quite a bit of USB related power saving by default, may become an annoyance
    };
  };

}
