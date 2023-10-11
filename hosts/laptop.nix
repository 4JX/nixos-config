inputs@{ nixpkgs, home-manager, nixos-hardware, hyprland, ... }:

let
  primaryUser = "infinity";

  system = "x86_64-linux"; # System architecture

  myLib = import ../lib { inherit (nixpkgs) lib; };

  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
      "mpv-betterChapters"
    ];
  };

  # Collection of custom packages
  p = {
    legion-kb-rgb = inputs.legion-kb-rgb.packages.${system}.wrapped;
  } // (pkgs.callPackage ../pkgs { inherit myLib; });

  nixosSystem = nixpkgs.lib.nixosSystem;
in
{
  inherit nixpkgs nixosSystem system;

  cfg = {
    specialArgs =
      {
        inherit primaryUser p myLib inputs;
        theme = import ../theme.nix;
      };

    modules = [
      nixos-hardware.nixosModules.lenovo-legion-16ach6h-hybrid
      home-manager.nixosModules.home-manager
      {
        # Use the same pkgs as the global nixpkgs
        home-manager.useGlobalPkgs = true;
        # Install stuff to /etc/profiles
        home-manager.useUserPackages = true;
        imports = [
          ../home
        ];

        home-manager.extraSpecialArgs = {
          inherit primaryUser;
        };
      }
      hyprland.nixosModules.default
      ./common.nix
      ./laptop
    ];
  };
}
