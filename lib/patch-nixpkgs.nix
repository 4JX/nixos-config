{
  originPkgs,
  system,
  remoteNixpkgsPatches,
  localNixpkgsPatches,
}:

# Allow patching nixpkgs
# https://github.com/NixOS/nixpkgs/pull/142273#issuecomment-948225922
# https://ertt.ca/nix/patch-nixpkgs/
# https://github.com/NixOS/nix/issues/3920#issuecomment-681187597

let
  inherit (originPkgs.legacyPackages.${system}) applyPatches fetchpatch;

  nixpkgs = applyPatches {
    name = "nixpkgs-patched";
    src = originPkgs;
    patches = map fetchpatch remoteNixpkgsPatches ++ localNixpkgsPatches;
    postPatch = ''
      patch=$(printf '%s\n' ${
        builtins.concatStringsSep " " (map (p: p.sha256) remoteNixpkgsPatches ++ localNixpkgsPatches)
      } |
        sort | sha256sum | cut -c -7)
      echo "_patch-$patch" >.version-suffix
    '';
  };
in
{
  inherit nixpkgs;

  # For Nixpkgs without (remote/local)NixpkgsPatches
  # nixosSystemUnpatched = nixpkgs.lib.nixosSystem;
  nixosSystem = import (nixpkgs + "/nixos/lib/eval-config.nix");
}
