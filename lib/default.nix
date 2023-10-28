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

  homeOption = config: option: builtins.mapAttrs (n: v: v.${option}) config.home-manager.users;
  homeOptionValues = config: option: builtins.attrValues homeOption config option;
in
{
  inherit initFlake homeOption homeOptionValues;

  recursiveMergeAttrs = lib.fold lib.recursiveUpdate { };

  patchNixpkgs = { nixpkgs, system, remoteNixpkgsPatches, localNixpkgsPatches }: import ./patch-nixpkgs.nix {
    inherit system remoteNixpkgsPatches localNixpkgsPatches;
    originPkgs = nixpkgs;
  };
}
