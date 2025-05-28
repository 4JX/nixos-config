{ pkgs, ... }:

pkgs.mkShell {
  packages = with pkgs; [
    (python3.withPackages (
      pyPkgs: with pyPkgs; [
        mkdocs
        mkdocs-material
        mkdocs-git-revision-date-localized-plugin
      ]
    ))
  ];
}
