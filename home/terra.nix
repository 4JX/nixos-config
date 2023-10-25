{ pkgs, mainUser, self, ... }:

let
  p = self.packages.${pkgs.system};
in
{
  hardware.ckb-next.enable = true;

  home-manager.users.${mainUser} = { pkgs, ... }: {
    home.packages = with pkgs; [
      kate
      keepassxc
      github-desktop
      spotify
      ark
      gh # Github CLI
      jetbrains.clion
      android-studio
      # handbrake
      vokoscreen-ng
      peek
      scrcpy
      tor-browser-bundle-bin
      arandr
      libreoffice
      obsidian
      node2nix
      cyberchef
      element-desktop
      figma-linux
      quassel
      p.portmaster
      dbeaver
      libsForQt5.okular
    ];

    home.stateVersion = "22.11";
  };

  ncfg = {
    programs = {
      networking = {
        sniffers = {
          wireshark.enable = true;
        };
      };

      gaming.enable = true;
    };

    misc = {
      screenshot-ocr = {
        enable = true;
        languages = [ "eng" "spa" ];
      };
    };
  };
}

