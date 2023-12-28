{ pkgs, homeFiles, self, ... }:
let
  p = self.packages.${pkgs.system};
in
{
  imports = [ ../modules ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";

  ncfg = {
    programs = {
      browsers.firefox = {
        enable = true;
        arkenfox = {
          overrides = {
            # This is a default since https://github.com/arkenfox/user.js/releases/tag/115.1
            # "keyword.enabled" = true;
          };
        };
      };

      editors = {
        vscodium = {
          enable = true;
          mutableExtensionsDir = true;
          useVSCodeMarketplace = true;
        };
      };
    };
  };

  home.packages = with pkgs; [
    kate
    keepassxc
    github-desktop
    gh # Github CLI
  ];
}
