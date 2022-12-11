final: prev:
let
  unstableTarball =
    fetchTarball
      "https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz";

  # TODO: Change source when pull request lands
  easyeffects_v7 = (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/13c891efa5309d1555fda72132ab4806609aff17.tar.gz") { config = prev.config; }).easyeffects;

  tlpui = (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/55cf28e91d51df77932da6c12dbf1b98ffa697b0.tar.gz") { config = prev.config; }).tlpui;
in
{
  unstable = prev.callPackage unstableTarball { };
  # https://github.com/NixOS/nixpkgs/issues/73323
  proton-ge-custom = prev.callPackage ./proton-ge-custom.nix { };

  easyeffects_v7 = easyeffects_v7;

  tlpui = tlpui;
}
