{ nixpkgs, ... }:

let
  inherit (nixpkgs) lib;

  initFlake = systems: config: f:
    lib.foldr lib.recursiveUpdate { } (
      map
        (
          system:
          f {
            inherit system;

            pkgs =
              if config == { } then
                nixpkgs.legacyPackages.${system}
              else
                import nixpkgs { inherit system config; };
          }
        )
        systems
    );
in
{
  inherit initFlake;

  recursiveMergeAttrs = lib.fold lib.recursiveUpdate { };

  patchNixpkgs = { nixpkgs, system, remoteNixpkgsPatches, localNixpkgsPatches }: import ./patch-nixpkgs.nix {
    inherit system remoteNixpkgsPatches localNixpkgsPatches;
    originPkgs = nixpkgs;
  };
}
