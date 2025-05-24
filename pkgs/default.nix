{ inputs, system, ... }:
let
  inherit (inputs.nixpkgs) lib;
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  callPackage =
    let
      defaultArgs = pkgs // {
        inherit inputs;
      };
    in
    lib.callPackageWith defaultArgs;

in
# https://github.com/NixOS/nixpkgs/blob/374e6bcc403e02a35e07b650463c01a52b13a7c8/lib/filesystem.nix#L379
lib.packagesFromDirectoryRecursive {
  inherit callPackage;
  directory = ./.;
}
