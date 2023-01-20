{ pkgs, config, lib, primaryUser, ... }:

let
  cfg = config.ncfg.shell.zsh;
in
{

  options.ncfg.shell.zsh = {
    enable = lib.mkEnableOption "Enable ZSH";

    shellAliases = lib.mkOption {
      default = { };
      type = lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {
    # Make zsh the default if enabled
    users.defaultUserShell = pkgs.zsh;
    environment.shells = with pkgs; [ zsh ];

    home-manager.users.${primaryUser} = { pkgs, ... }: {
      programs.zsh = {
        enable = true;
        enableAutosuggestions = true;

        inherit (cfg) shellAliases;

        plugins = [
          {
            name = "fast-syntax-highlighting";
            file = "fast-syntax-highlighting.plugin.zsh";
            src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
          }
          {
            name = "zsh-colored-man-pages";
            file = "colored-man-pages.plugin.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "ohmyzsh";
              repo = "ohmyzsh";
              rev = "d3bb52d7d825f2a6ce2e1c76ca472b05c6f27b40";
              sha256 = "sha256-087bNmB5gDUKoSriHIjXOVZiUG5+Dy9qv3D69E8GBhs=";
            };
          }
          {
            name = "zsh-nix-shell";
            file = "nix-shell.plugin.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "chisui";
              repo = "zsh-nix-shell";
              rev = "v0.5.0";
              sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
            };
          }
        ];
      };
    };
  };
}
