{ inputs, self, pkgs, ... }:

let
  p = self.packages.${pkgs.system};
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

    DM = {
      autoLogin = false;
      loginUser = "infinity";
      gdm.enable = true;
    };
    DE.gnome.enable = true;
    WM.hyprland.enable = true;

    system = {
      sound.enable = true;
      gnome-keyring.enable = true;

      flatpak.enable = true;
      fonts = {
        custom = with p.fonts; [
          apple-fonts
          custom-fonts
        ];
      };
      security = {
        usbguard = {
          enable = true;
          rules = builtins.readFile ./usbguard-rules.conf;
        };
      };
    };

    programs = {
      gaming.enable = true;
    };
  };

  environment.shellAliases = {
    enable-conservation-mode = "echo 1 | sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode";
    disable-conservation-mode = "echo 0 | sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode";
    turn-off-keyboard = "${legion-kb-rgb}/bin/legion-kb-rgb set --effect Static -c 0,0,0,0,0,0,0,0,0,0,0,0";
  };
}
