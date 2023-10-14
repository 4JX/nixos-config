{
  description = "Personal NixOS configuration";

  outputs = inputs@{ self, nixpkgs, home-manager, nixos-hardware, hyprland, ... }:
    let
      machines = builtins.mapAttrs
        (machineName: machineConfig:
          let
            inherit (import machineConfig inputs) cfg nixosSystem;
          in

          nixosSystem (cfg // {
            specialArgs = { } // (cfg.specialArgs or { });

            modules = cfg.modules ++ [
              self.nixosModules
              (_: {
                # Set the hostName to the one specified in the machine name
                networking.hostName = machineName;
              })
            ];
          })
        );
    in
    {
      nixosConfigurations = machines {
        nixos = ./hosts/laptop.nix;
      };

      nixosModules = ./modules;

      packages.x86_64-linux =
        let
          system = "x86_64-linux"; # System architecture

          myLib = import ./lib { inherit inputs; };

          pkgs = import nixpkgs {
            inherit system;

            config.allowUnfree = true;
          };
        in
        pkgs.callPackage ./pkgs { inherit myLib; };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      # url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    programsdb = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    arkenfox = {
      url = "github:arkenfox/user.js";
      flake = false;
    };

    # -- Extra packages --
    legion-kb-rgb = {
      url = "github:4JX/L5P-Keyboard-RGB";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
    
