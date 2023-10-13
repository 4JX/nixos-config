{ inputs, pkgs, ... }:

let
  p = inputs.self.packages.${pkgs.system};
  legion-kb-rgb = inputs.legion-kb-rgb.packages.${pkgs.system}.wrapped;
in
{
  ncfg = {
    allowedUnfree = [
      "spotify"
      "clion"
      "android-studio-stable"
      "obsidian"
      "nvidia-x11"
      "cudatoolkit"
      "nvidia-settings"
      "steam"
      "steam-original"
      "steam-run"
    ];

    DE.gnome.enable = true;
    WM.hyprland.enable = true;

    system = {
      flatpak.enable = true;
      fonts = {
        enableCommonFonts = true;
        custom = with p.fonts; [
          apple-fonts
          custom-fonts
        ];
      };
      pipewire = {
        enable = true;
        extraRates = true;
      };
      power-management = {
        tlp = {
          enable = true;
          # https://linrunner.de/tlp/settings/operation.html
          # https://linrunner.de/tlp/support/optimizing.html
          # https://linrunner.de/tlp/faq/powercon.html
          # Made for version 
          settings = {
            # https://linrunner.de/tlp/settings/audio.html#sound-power-save-on-ac-bat
            SOUND_POWER_SAVE_ON_AC = 0; # Default 1
            SOUND_POWER_SAVE_ON_BAT = 1;

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

        # The repo seems to be dead/archived sadly
        power-profiles-daemon.enable = false;
      };
      gnome-keyring.enable = true;
      networkmanager.enable = true;
      colord-kde.enable = true;
      security = {
        usbguard = {
          enable = true;
          rules = builtins.readFile ./usbguard-rules.conf;
        };
      };
    };

    shell.zsh.shellAliases = {
      # turn-off-keyboard = "sudo ${legion-kb-rgb}/bin/legion-kb-rgb set --effect Static -c 0,0,0,0,0,0,0,0,0,0,0,0";
    };
  };
}
