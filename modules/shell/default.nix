{ pkgs, config, ... }:

{
  imports = [
    ./zsh.nix
    ./starship.nix
    ./kitty.nix
  ];
}
