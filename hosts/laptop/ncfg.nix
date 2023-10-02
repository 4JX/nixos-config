{ p, ... }:

{
  ncfg = {
    gnome.enable = true;

    system = {
      flatpak.enable = true;
      fonts = {
        enableCommonFonts = true;
        custom = [
          p.fonts.apple-fonts
        ];
      };
      pipewire = {
        enable = true;
        extraRates = true;
      };
      power-management = {
        enable = true;

        blacklistAmdPstate = false;

        power-profiles-daemon.enable = true;

        tlp.enable = false;

        auto-cpufreq = {
          enable = false;
          configPath = ./auto-cpufreq.conf;
        };
      };
      gnome-keyring.enable = true;
      networkmanager.enable = true;
      colord-kde.enable = true;
      hyprland.enable = true;
      security = {
        usbguard = {
          enable = true;
          rules = builtins.readFile ./usbguard-rules.conf;
        };
      };
    };

    shell.zsh.shellAliases = {
      # turn-off-keyboard = "sudo ${p.legion-kb-rgb}/bin/legion-kb-rgb set --effect Static -c 0,0,0,0,0,0,0,0,0,0,0,0";
    };
  };
}
