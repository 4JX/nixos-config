{ self, myLib, ... }:

let
  inherit (self) inputs;
  inherit (self.inputs.nixpkgs) lib;
  inherit (lib) concatLists;


  hm = inputs.home-manager.nixosModules.home-manager;
  hw = inputs.nixos-hardware.nixosModules;

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

  mkHosts = builtins.mapAttrs (hostName: config: nixosSystem {
    specialArgs = commonArgs // config.specialArgs;

    modules = config.modules ++ [
      {
        networking = { inherit hostName; };
      }
      ./${hostName}
    ] ++ concatLists [ shared homes ];
  });
in
mkHosts {
  terra =
    {
      specialArgs = { };

      modules = [
        hw.lenovo-legion-16ach6h-hybrid
        laptop
      ];
    };
}
