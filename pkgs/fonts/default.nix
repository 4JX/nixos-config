{ pkgs, ... }:

{
  apple-fonts = pkgs.callPackage ./apple-fonts.nix { };
  custom-fonts = pkgs.callPackage ./custom-fonts.nix { };
}
