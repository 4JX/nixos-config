# Keeps the comma database in check

{ inputs, ... }:

{
  imports = [ inputs.nix-index-database.hmModules.nix-index ];

  programs = {
    nix-index-database.comma.enable = true;

    # Depends on a nix-channel database, replace with
    # nix-index instead, which mostly works the same
    command-not-found.enable = false;

    nix-index = {
      enable = true;
    };
  };
}
