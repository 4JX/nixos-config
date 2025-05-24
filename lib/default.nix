{ nixpkgs, ... }:

let
  inherit (nixpkgs) lib;

  homeOption = config: option: builtins.mapAttrs (_n: v: v.${option}) config.home-manager.users;
  homeOptionValues = config: option: builtins.attrValues homeOption config option;
in
{
  inherit homeOption homeOptionValues;

  recursiveMergeAttrs = lib.fold lib.recursiveUpdate { };

  patchNixpkgs =
    {
      nixpkgs,
      system,
      remoteNixpkgsPatches,
      localNixpkgsPatches,
    }:
    import ./patch-nixpkgs.nix {
      inherit system remoteNixpkgsPatches localNixpkgsPatches;
      originPkgs = nixpkgs;
    };

  mkVersionAssertion = pkg: currentVersion: {
    assertion = builtins.compareVersions pkg.version currentVersion == 0;
    message = "Package ${pkg.name} (${pkg.version}) is no longer version ${currentVersion}.";
  };
}
