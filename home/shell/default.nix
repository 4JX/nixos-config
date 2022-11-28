{ pkgs, config, ... }:


let
  cfg = config.cfg;
in
{
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  home-manager.users.${cfg.user} = { pkgs, ... }: {
    imports = [ ./zsh.nix ./starship.nix ];
  };
}

