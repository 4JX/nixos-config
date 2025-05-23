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

    DM = {
      autoLogin = false;
      loginUser = "infinity";
    };
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

    wireguard.server = {
      enable = false;
      interfaces = {
        external = "enp2s0";
      };
      peers = [
        {
          name = "user";
          publicKey = "3lpnmjSy+yGkTvZDHcurVEK4yZqEiq73Csj/DxB6I1g=";
          presharedKey = "9ctI8KMwoy6nswTPI1c8o2oETEJdiCmh0XRUDEvfTYU=";
          # presharedKeyFile = "/use/me/for/your/preshared/key";
          allowedIPs = [ "10.100.0.2/32" ];
        }
      ];
    };
  };
}
