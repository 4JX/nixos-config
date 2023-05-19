_:

{
  patchNixpkgs = { nixpkgs, system, remoteNixpkgsPatches, localNixpkgsPatches }: import ./patch-nixpkgs.nix {
    inherit system remoteNixpkgsPatches localNixpkgsPatches;
    originPkgs = nixpkgs;
  };
}
