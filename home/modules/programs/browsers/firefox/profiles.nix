{ pkgs, lib, ... }:

# Automating the firefox version, well enough behaved:
# https://github.com/danielphan2003/flk/blob/198bf56b8dde0c075f89f58952bedfa85e0b3cf7/cells/home/homeProfiles/programs/firefox/arkenfox.nix

let
  engine-logos = ./engine-logos;

  profileDirs = builtins.readDir ./profiles;

  profiles = lib.pipe profileDirs [
    (lib.filterAttrs (_: v: v == "directory"))
    (builtins.mapAttrs (dir: _: processProfile (./profiles + "/${dir}")))
  ];

  processProfile =
    p:
    let
      mkImport =
        { name, attrs }:
        let
          importPath = p + "/${name}.nix";
        in
        if builtins.pathExists importPath then import importPath attrs else { };
    in
    {
      search = mkImport {
        name = "search";
        attrs = { inherit pkgs engine-logos; };
      };
      arkenfox = mkImport {
        name = "arkenfox";
        attrs = { };
      };
    }
    // (import (p + /config.nix) { });
in
profiles
