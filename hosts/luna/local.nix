{ self, pkgs, ... }:

let
  p = self.packages.${pkgs.system};
in
{
  local = {
    allowedUnfree = [
      "nvidia-x11"
      "nvidia-settings"
    ];

    DE.xfce.enable = true;

    system = {
      sound.enable = true;
      gnome-keyring.enable = true;

      dns = {
        cloudflare-resolved = {
          enable = true;
        };
        dnscrypt = {
          enable = false;
          # configFile = config.sops.secrets.dnscryptConfigFile.path;
        };
      };

      flatpak.enable = true;

      fonts = {
        custom = with p.fonts; [
          apple-fonts
          custom-fonts
        ];
      };
    };
  };
}
