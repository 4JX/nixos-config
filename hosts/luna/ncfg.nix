{ self, pkgs, config, ... }:

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
      "spotify"
      "clion"
      "android-studio-stable"
      "obsidian"
      "nvidia-x11"
      # "cudatoolkit"
      "nvidia-settings"
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
      "cups-brother-hl3140cw-1.1.4-0"
    ];

    DM = {
      autoLogin = false;
      loginUser = "infinity";
      gdm.enable = true;
    };
    DE.gnome.enable = true;

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
  };
}
