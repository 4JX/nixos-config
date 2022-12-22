final: prev:

{
  # https://github.com/NixOS/nixpkgs/issues/73323
  proton-ge-custom = prev.callPackage ./proton-ge-custom.nix { };
}
