{ p, ... }:

{
  ncfg = {
    gnome.enable = true;

    system = {
      flatpak.enable = true;
      fonts = {
        enableCommonFonts = true;
      };
      pipewire = {
        enable = true;
        extraRates = true;
      };
      power-management = {
        enable = true;
        # Pstate is not quite there yet energy saving wise
        blacklistAmdPstate = true;
        auto-cpufreq.configPath = ./auto-cpufreq.conf;
      };
      gnome-keyring.enable = true;
      networkmanager.enable = true;
      colord-kde.enable = true;
      hyprland.enable = true;
    };

    shell.zsh.shellAliases = {
      turn-off-keyboard = "sudo ${p.legion-kb-rgb}/bin/legion-kb-rgb set --effect Static -c 0,0,0,0,0,0,0,0,0,0,0,0";
    };
  };
}
