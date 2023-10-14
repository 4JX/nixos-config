{ inputs, self, pkgs, primaryUser, ... }:

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
      autoLogin = true;
      loginUser = primaryUser;
      gdm.enable = true;
    };
    DE.gnome.enable = true;
    WM.hyprland.enable = true;

    system = {
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

    shell.zsh.shellAliases = {
      turn-off-keyboard = "${legion-kb-rgb}/bin/legion-kb-rgb set --effect Static -c 0,0,0,0,0,0,0,0,0,0,0,0";
    };
  };
}
