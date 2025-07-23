{
  lib,
  config,
  ...
}:

{
  imports = [
    ./DE
    ./DM
    ./misc
    ./programs
    ./system
    ./virtualisation
    ./command-not-found.nix
    ./nix.nix
    ./sops.nix
  ];

  # Fix home-manager's home.sessionVariables not being sourced on DE's
  # https://rycee.gitlab.io/home-manager/index.html#_why_are_the_session_variables_not_set
  # https://github.com/hpfr/system/blob/a108a5ebf3ffcee75565176243936de6fd736142/profiles/system/base.nix#L12-L16
  # https://github.com/nix-community/home-manager/issues/1011
  environment.extraInit =
    let
      users = builtins.attrNames config.home-manager.users;

      sourceForUser = user: ''
        if [ "$(id -un)" = "${user}" ]; then
          . "/etc/profiles/per-user/${user}/etc/profile.d/hm-session-vars.sh"
        fi
      '';
    in
    lib.concatLines (builtins.map sourceForUser users);
}
