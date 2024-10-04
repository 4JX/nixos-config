{ lib, inputs, pkgs, config, ... }:

# Stuff that is unconditionally imported to fix flake shenanigans and co.
let
  isFlake = (lib.filterAttrs (_: lib.isType "flake"));
in
{
    imports = [
    ./DE
    ./DM
    ./gaming
    ./misc
    ./system
    ./virtualisation
    ./WM
    ./sops.nix
  ];
  
  # Resolve <nixpkgs> and other references to the flake input
  # https://ayats.org/blog/channels-to-flakes/
  # https://github.com/Gerg-L/nixos/blob/681ea1529269dbc62652e8368c7f4f1f659c661f/modules/nix.nix#L9-L16 
  nix.registry = lib.pipe inputs [
    isFlake
    (lib.mapAttrs (_: flake: { inherit flake; }))
  ];

  nix.nixPath = lib.pipe inputs [
    isFlake
    (lib.mapAttrsToList (n: _: "${n}=flake:${n}"))
  ];

  # Needed for all configs to run on flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Fix command-not-found issues with db
  # https://blog.nobbz.dev/2023-02-27-nixos-flakes-command-not-found/
  environment.etc."programs.sqlite".source = inputs.programsdb.packages.${pkgs.system}.programs-sqlite;
  programs.command-not-found.dbPath = "/etc/programs.sqlite";

  # Fix home-manager's home.sessionVariables not being sourced on DE's
  # https://rycee.gitlab.io/home-manager/index.html#_why_are_the_session_variables_not_set
  # https://github.com/hpfr/system/blob/a108a5ebf3ffcee75565176243936de6fd736142/profiles/system/base.nix#L12-L16
  # https://github.com/nix-community/home-manager/issues/1011
  environment.extraInit =
    let
      users = builtins.attrNames config.home-manager.users;

      sourceForUser = (user: ''
        if [ "$(id -un)" = "${user}" ]; then
          . "/etc/profiles/per-user/${user}/etc/profile.d/hm-session-vars.sh"
        fi
      '');
    in
    lib.concatLines (builtins.map sourceForUser users);
}

