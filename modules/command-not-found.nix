{ inputs, pkgs, ... }:

{
  # Fix command-not-found issues with db
  # https://blog.nobbz.dev/blog/2023-02-27-nixos-flakes-command-not-found/
  environment.etc."programs.sqlite".source =
    inputs.programsdb.packages.${pkgs.stdenv.hostPlatform.system}.programs-sqlite;
  programs.command-not-found.dbPath = "/etc/programs.sqlite";
}
