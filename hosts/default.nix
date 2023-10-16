{ self, myLib, ... }:

let
  inherit (self) inputs;
  inherit (self.inputs.nixpkgs) lib;
  inherit (lib) concatLists;


  hm = inputs.home-manager.nixosModules.home-manager;
  hw = inputs.nixos-hardware.nixosModules;
  hypr = inputs.hyprland.nixosModules.default;

  nixosSystem = inputs.nixpkgs.lib.nixosSystem;

  theme = import ../theme.nix;

  # Where the modules are located
  modulePath = ../modules;

  options = modulePath + /options; # Option declarations
  common = modulePath + /common; # Defaults shared across systems
  laptop = modulePath + /laptop.nix; # Options specific for laptops, currently only enables power management

  homesDir = ../home;

  shared = [ options common ];
  homes = [ hm homesDir ];

  commonArgs = { inherit inputs self myLib theme; };
in
{
  nixos =
    let
      primaryUser = "infinity";
    in
    nixosSystem {
      specialArgs = commonArgs // { inherit primaryUser; };

      modules = [
        {
          networking.hostName = "nixos";
        }
        hw.lenovo-legion-16ach6h-hybrid
        ./laptop
        ../home/laptop.nix
        hypr
      ] ++ concatLists [ shared homes ] ++ [ laptop ];
    };
}
