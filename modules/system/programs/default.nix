{ pkgs, ... }:

{
  # Technically should use users.users.<username>.shell but this is more convenient
  users.defaultUserShell = pkgs.zsh;

  programs = {
    # Because home-manager needs it
    zsh.enable = true;

    # https://search.nixos.org/options?channel=unstable&show=programs.pay-respects.runtimeRules
    pay-respects.enable = true;

    # Allows loading mini-envs on a per-directory basis
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
