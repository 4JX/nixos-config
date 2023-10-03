{ pkgs, config, lib, primaryUser, ... }:

let
  cfg = config.ncfg.shell.zsh;
in
{

  options.ncfg.shell.zsh = {
    enable = lib.mkEnableOption "ZSH";

    shellAliases = lib.mkOption {
      default = { };
      type = lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {
    # Make zsh the default if enabled
    users.defaultUserShell = pkgs.zsh;
    environment.shells = with pkgs; [ zsh ];
    programs.zsh.enable = true;

    home-manager.users.${primaryUser} = { pkgs, ... }: {
      programs.zsh = {
        enable = true;
        enableAutosuggestions = true;

        # https://github.com/nix-community/home-manager/issues/3965
        # https://github.com/NixOS/nixpkgs/blob/fd40cef8d797670e203a27a91e4b8e6decf0b90c/nixos/modules/programs/zsh/zsh.nix#L149-L160
        # https://github.com/nix-community/home-manager/blob/78ceec68f29ed56d6118617e9f0f588bf164067f/modules/programs/zsh.nix#L290-L306
        # When using enable = true in both nixpkgs and home-manager zsh slows down a bunch
        # Disable "initialising" completion in home-manager since it is already enabled by default
        # in nixpkgs with programs.zsh.enableCompletion (which affects enableCompletion)
        # This also removes the automatic addition of nix-zsh-completions, but it's added back anyways
        enableCompletion = false;

        inherit (cfg) shellAliases;

        plugins = [
          {
            name = "fast-syntax-highlighting";
            file = "fast-syntax-highlighting.plugin.zsh";
            src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
          }
          {
            name = "zsh-nix-shell";
            file = "nix-shell.plugin.zsh";
            src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
          }
          {
            name = "nix-zsh-shell-completions";
            file = "nix-zsh-completions.plugin.zsh";
            src = "${pkgs.nix-zsh-completions}/share/zsh/site-functions";
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
          # {
          #   name = "zsh-nix-shell";
          #   file = "nix-shell.plugin.zsh";
          #   src = pkgs.fetchFromGitHub {
          #     owner = "chisui";
          #     repo = "zsh-nix-shell";
          #     rev = "v0.5.0";
          #     sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
          #   };
          # }
        ];
      };
    };
  };
}
