{
  description = "Personal NixOS configuration";

  outputs = inputs:
    let
      machines = builtins.mapAttrs
        (machineName: machineConfig:
          let
            inherit (import machineConfig inputs) cfg nixosSystem nixpkgs system;
          in

          nixosSystem (cfg // {
            specialArgs = { } // (cfg.specialArgs or { });

            modules = cfg.modules ++ [
              ./modules
              (_: {
                # Set the hostName to the one specified in the machine name
                networking.hostName = machineName;

                # Resolve <nixpkgs> and other references to the flake input
                # https://ayats.org/blog/channels-to-flakes/
                nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
                nix.registry.nixpkgs.flake = nixpkgs;

                # Needed for all configs to run on flakes
                nix.settings.experimental-features = [ "nix-command" "flakes" ];

                # Fix command-not-found issues with db
                # https://blog.nobbz.dev/2023-02-27-nixos-flakes-command-not-found/
                environment.etc."programs.sqlite".source = inputs.programsdb.packages.${system}.programs-sqlite;
                programs.command-not-found.dbPath = "/etc/programs.sqlite";
              })
            ];
          })
        );
    in
    {
      nixosConfigurations = machines {
        nixos = ./hosts/laptop.nix;
      };
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
      url = "github:4JX/L5P-Keyboard-RGB/gui-but-better";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
    
