{
  lib,
  inputs,
  ...
}:

# Stuff that is unconditionally imported to fix flake shenanigans and co.
let
  isFlake = lib.filterAttrs (_: lib.isType "flake");
in
{
  nix = {
    # Fully disable nix channels
    channel.enable = false;

    # Resolve <nixpkgs> and other references to the flake input
    # https://ayats.org/blog/channels-to-flakes/
    # https://github.com/Gerg-L/nixos/blob/681ea1529269dbc62652e8368c7f4f1f659c661f/modules/nix.nix#L9-L16
    registry = lib.pipe inputs [
      isFlake
      (lib.mapAttrs (_: flake: { inherit flake; }))
    ];

    nixPath = lib.pipe inputs [
      isFlake
      (lib.mapAttrsToList (n: _: "${n}=flake:${n}"))
    ];

    settings = {
      experimental-features = [
        # Needed for all configs to run on flakes
        "nix-command"
        "flakes"
        # Outright prohibit unquoted URL literals
        "no-url-literals"
      ];
      # Save some space without explicitly deleting
      auto-optimise-store = true;
    };
  };
}
