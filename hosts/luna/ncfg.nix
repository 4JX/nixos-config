{ self, pkgs, ... }:

let
  p = self.packages.${pkgs.system};
in
{
  # sops.secrets.dnscryptConfigFile = {
  #   format = "binary";
  #   sopsFile = config.lib.sops.mkHostPath "dnscrypt-proxy.toml";
  #   # The service set up by nixos has DynamicUser=true, best one can do is have it be world readable by anyone
  #   mode = "0444";
  # };

  ncfg = {
    allowedUnfree = [
      "nvidia-x11"
      "nvidia-settings"
    ];

    DM = {
      autoLogin = false;
      loginUser = "infinity";
    };
    DE.xfce.enable = true;

    system = {
      sound.enable = true;
      gnome-keyring.enable = true;

      dnscrypt = {
        enable = false;
        # configFile = config.sops.secrets.dnscryptConfigFile.path;
      };

      flatpak.enable = true;

      fonts = {
        custom = with p.fonts; [
          apple-fonts
          custom-fonts
        ];
      };
    };

    servarr = {
      enable = true;
      recyclarr.enable = true;
      qbittorrent = {
        firewall = {
          open = true;
          incomingPort = 64793;
        };
      };
    };
  };
}