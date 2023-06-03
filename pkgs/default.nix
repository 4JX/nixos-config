{ pkgs, lib }:


{
  # https://github.com/NixOS/nixpkgs/issues/73323
  proton-ge-custom = pkgs.callPackage ./proton-ge-custom.nix { };
  proton-ge-custom-621 = pkgs.callPackage ./proton-ge-custom-6.21-2.nix { };
  vimix-cursor-theme = pkgs.callPackage ./vimix-cursors.nix { };
  portmaster = pkgs.callPackage ./portmaster.nix { };
}
  // (lib.recursiveUpdate { mpv = pkgs.callPackage ./mpv { }; } (pkgs.callPackage ./pull-requests { }))
