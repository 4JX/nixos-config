_final: prev:

{
  # https://github.com/NixOS/nixpkgs/issues/73323
  proton-ge-custom = prev.callPackage ./proton-ge-custom.nix { };
  proton-ge-custom-621 = prev.callPackage ./proton-ge-custom-6.21-2.nix { };
}
