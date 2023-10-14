inputs@{ nixpkgs, home-manager, nixos-hardware, hyprland, ... }:

let
  primaryUser = "infinity";

  myLib = import ../lib { inherit inputs; };

  nixosSystem = nixpkgs.lib.nixosSystem;
in
{
  inherit nixosSystem;

  cfg = {
    specialArgs =
      {
        inherit primaryUser myLib inputs;
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
