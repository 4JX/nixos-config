{ pkgs, ... }:

{
  # Technically should use users.users.<username>.shell but this is more convenient
  users.defaultUserShell = pkgs.zsh;

  programs = {
    # Because home-manager needs it
    zsh.enable = true;

    # Run commands without installing the programs
    # TODO: steal https://github.com/NotAShelf/nyx/blob/c182362cd0e848a9175d836289596860cfacb08f/modules/extra/shared/nixos/comma/default.nix#L6
    # comma.enable = true;

    # Type "fuck" to fix the last command that made you go "fuck"
    thefuck.enable = true;

    # Allows loading mini-envs on a per-directory basis
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
