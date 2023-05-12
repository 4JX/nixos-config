{ pkgs, lib }:


{
  # https://github.com/NixOS/nixpkgs/issues/73323
  proton-ge-custom = pkgs.callPackage ./proton-ge-custom.nix { };
  proton-ge-custom-621 = pkgs.callPackage ./proton-ge-custom-6.21-2.nix { };
}
  // (lib.recursiveUpdate (pkgs.callPackage ./mpv { }) (pkgs.callPackage ./pull-requests { }))
