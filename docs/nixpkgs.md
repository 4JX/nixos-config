# Nixpkgs

[Manual reference](https://nixos.org/manual/nixpkgs/stable/)

## Lib

### lib.filesystems.packagesFromDirectoryRecursive

[Reference](<https://nixos.org/manual/nixpkgs/stable/#function-library-lib.filesystem.packagesFromDirectoryRecursive>) - [Definition](<https://github.com/NixOS/nixpkgs/blob/374e6bcc403e02a35e07b650463c01a52b13a7c8/lib/filesystem.nix#L379>)

Automagically turns a tree of files into callPackage'd packages

## pkgs

### callPackage

`import` but with automatic argument passing.

[Definition](<https://github.com/NixOS/nixpkgs/blob/e1e2f77161214578ab7bbc7c746d20ca3553ca66/pkgs/top-level/splice.nix#L170>) - [Explanation by Nobbz](<https://blog.nobbz.dev/blog/2022-09-17-callpackage-a-tool-for-the-lazy/>)

Basically [`callPackageWith`](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.customisation.callPackageWith) with the passed attributes being that instance of `pkgs`.
