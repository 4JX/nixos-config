{
  inputs,
  self,
  pkgs,
  config,
  ...
}:

let
  p = self.packages.${pkgs.stdenv.hostPlatform.system};
  legion-kb-rgb = inputs.legion-kb-rgb.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  sops.secrets.dnscryptConfigFile = {
    format = "binary";
    sopsFile = config.lib.sops.mkHostPath "dnscrypt-proxy.toml";
    # The service set up by nixos has DynamicUser=true, best one can do is have it be world readable by anyone
    mode = "0444";
  };

  local = {
    allowedUnfree = [
      "spotify"
      "clion"
      "obsidian"
      "nvidia-x11"
      # "cudatoolkit"
      "nvidia-settings"
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
      "Oracle_VirtualBox_Extension_Pack"
    ];

    DM = {
      gdm.enable = true;
    };
    DE.gnome.enable = true;

    system = {
      sound.enable = true;
      gnome-keyring.enable = true;

      dns = {
        dnscrypt = {
          enable = true;
          configFile = config.sops.secrets.dnscryptConfigFile.path;
        };
      };

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

      hdr = {
        enable = true;
      };
    };

    programs = {
      gaming.enable = true;
      comma.enable = true;
    };

    virtualisation = {
      virtualbox = {
        enable = true;
        enableExtensionPack = true;
        enableKvm = false;
      };
    };
  };

  environment.shellAliases = {
    enable-conservation-mode = "echo 1 | sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode";
    disable-conservation-mode = "echo 0 | sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode";
    turn-off-keyboard = "${legion-kb-rgb}/bin/legion-kb-rgb set --effect Static -c 0,0,0,0,0,0,0,0,0,0,0,0";
  };
}
