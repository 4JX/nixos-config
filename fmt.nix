# TODO: Flakepartify it eventually
# https://github.com/mobusoperandi/website/blob/9be56a911bb786f9f4f429ecc661d52b09ee87e2/fmt.nix#L3
{ ... }:
{
  projectRootFile = "flake.nix";
  programs = {
    # rfc-style
    # https://github.com/numtide/treefmt-nix/blob/main/programs/nixfmt.nix
    nixfmt = {
      enable = true;
      # strict = false;
      # width = 100;
    };
    # https://github.com/numtide/treefmt-nix/blob/main/programs/deadnix.nix
    deadnix = {
      enable = true;
      # Don't check lambda parameter arguments
      # no-lambda-arg = false;
      # Don't check lambda attrset pattern names (don't break nixpkgs callPackage)
      # no-lambda-pattern-names = false;
      # Don't check any bindings that start with a _
      # no-underscore = false;
    };
    # https://github.com/numtide/treefmt-nix/blob/main/programs/statix.nix
    statix = {
      enable = true;
      # List of ignored lints. Run `statix list` to see all available lints.
      disabled-lints = [
        # This changes { ... } to _, which is not wanted
        # deadnix handles this correctly
        "empty_pattern"
      ];

    };
    # https://github.com/numtide/treefmt-nix/blob/main/programs/yamlfmt.nix
    yamlfmt = {
      enable = true;
    };
    # Would rather markdownlint: https://github.com/numtide/treefmt-nix/issues/227
    # https://github.com/numtide/treefmt-nix/blob/main/programs/mdsh.nix
    # mdsh = {
    #   enable = true;
    #   includes = lib.mkForce [ "*.md" ];
    # };
    # https://github.com/numtide/treefmt-nix/blob/main/programs/shellcheck.nix
    shellcheck = {
      enable = true;
    };
  };
  settings = {
    # on-unmatched = "warn";
    # on-unmatched = "fatal";
    global.excludes = [
      ".editorconfig"
      "LICENSE"
      "secrets/*"
    ];
  };
}
