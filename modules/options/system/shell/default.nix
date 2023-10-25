{ ... }:

{
  imports = [
    ./zsh.nix
    ./starship.nix
    ./kitty.nix
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
