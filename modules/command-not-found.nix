{
  inputs,
  pkgs,
  ...
}:

{
  # Fix command-not-found issues with db
  # https://blog.nobbz.dev/blog/2023-02-27-nixos-flakes-command-not-found/
  programs = {
    command-not-found = {
      enable = true;
      dbPath = inputs.programsdb.packages.${pkgs.stdenv.hostPlatform.system}.programs-sqlite;
    };

    # Keep nix-locate available without replacing the faster programs.sqlite
    # command-not-found hook.
    nix-index = {
      enableBashIntegration = false;
      enableZshIntegration = false;
      enableFishIntegration = false;
    };
  };
}
