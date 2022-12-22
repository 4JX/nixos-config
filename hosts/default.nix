{ inputs, nixpkgs, home-manager, nixos-hardware, primaryUser, ... }:

let
  system = "x86_64-linux"; # System architecture

  overlay = final: prev: {
    unstable = inputs.nixpkgs-unstable.legacyPackages.${prev.system};

    inherit (inputs.nixpkgs-tlpui.legacyPackages.${prev.system})
      tlpui;
  };

  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfree = true;
    overlays = [ (import ../pkgs) overlay ];
  };

  lib = nixpkgs.lib;
in
{
  nixos = lib.nixosSystem {
    inherit system pkgs;

    specialArgs =
      {
        inherit primaryUser;
        hostName = "nixos";
        theme = import ./theme.nix;
      };

    modules = [
      nixos-hardware.nixosModules.lenovo-legion-16ach6h-hybrid
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        imports = [ ./home ];
      }
      ./configuration.nix
      ./laptop
    ];
  };
}
