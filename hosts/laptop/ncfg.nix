{ inputs, pkgs, ... }:

let
  p = inputs.self.packages.${pkgs.system};
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
        enable = true;

        power-profiles-daemon.enable = true;
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
      # turn-off-keyboard = "sudo ${p.legion-kb-rgb}/bin/legion-kb-rgb set --effect Static -c 0,0,0,0,0,0,0,0,0,0,0,0";
    };
  };
}
