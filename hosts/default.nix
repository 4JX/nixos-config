{ inputs, nixpkgs, home-manager, nixos-hardware, hyprland, primaryUser, ... }:

let
  system = "x86_64-linux"; # System architecture

  # An instance of Nixpkgs used solely for instatiating the custom packages with callPackage
  pkgsCall = import nixpkgs {
    inherit system;

    config.allowUnfree = true;
  };

  # Collection of custom packages
  p = {
    legion-kb-rgb = inputs.legion-kb-rgb.packages.${system}.wrapped;
  } // (pkgsCall.callPackage ../pkgs { });

  overlay = _final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit system;

      config.allowUnfree = true;
    };

    # Needed for services.auto-cpufreq.enable
    inherit (p) auto-cpufreq;
  };

  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfree = true;
    overlays = [ overlay ];
  };

  inherit (nixpkgs) lib;
in
{
  nixos = lib.nixosSystem {
    inherit system pkgs;

    specialArgs =
      {
        inherit primaryUser p;
        hostName = "nixos";
        theme = import ./theme.nix;
      };

    modules = [
      nixos-hardware.nixosModules.lenovo-legion-16ach6h-hybrid
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        imports = [
          ./home
        ];
      }
      hyprland.nixosModules.default
      ./configuration.nix
      ./laptop
    ];
  };
}
