{ inputs, ... }:

{
  imports = [
    inputs.nix-colors.homeManagerModule
    ./cursor.nix
    ./gtk.nix
    ./qt.nix
  ];

  inherit ((import ./palettes/plastic.nix)) colorScheme;
}
