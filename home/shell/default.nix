{ pkgs, config, primaryUser, ... }:

{
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  home-manager.users.${primaryUser} = { pkgs, ... }: {
    imports = [ ./zsh.nix ./starship.nix ];
  };
}

