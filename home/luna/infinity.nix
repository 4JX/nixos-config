{ pkgs, ... }:
{
  imports = [ ../modules ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";

  local = {
    programs = {
      browsers.firefox = {
        enable = true;
      };

      editors = {
        vscodium = {
          enable = true;
          mutableExtensionsDir = true;
          useVSCodeMarketplace = true;
        };
      };

      misc = {
        screenshot-ocr = {
          enable = true;
          languages = [
            "eng"
            "spa"
          ];
        };
      };

      video = {
        mpv.enable = true;
      };
    };
  };

  services.caffeine.enable = true;

  home.packages = with pkgs; [
    kdePackages.kate
    keepassxc
    github-desktop
    kdePackages.ark
    gh # Github CLI
    tor-browser-bundle-bin
    arandr
    libsForQt5.okular

    fractal
    kdePackages.filelight

    # Filesharing but easy
    localsend
  ];
}
